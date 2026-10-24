using System.Buffers;
using System.Text;
using System.Text.Json;

namespace CpTower;

internal enum AhpEnvelopeKind {
    Batch,
    Capabilities,
    Closed,
    Payload,
    Pending,
}

internal readonly record struct AhpEnvelopeResult(
    AhpEnvelopeKind Kind, IReadOnlyList<byte[]> Payloads, long? Generation = null);

internal sealed class AhpEnvelopeCodec {
    private const int ChunkBytes = 614_400;
    private const int MaxAssemblies = 64;
    private const int MaxPayloadBytes = 33_554_432;
    private const int MaxSegments = 4096;
    private const int MaxSingleEnvelopeBytes = 921_600;

    private readonly Dictionary<string, Assembly> assemblies = [];

    public IReadOnlyList<BinaryData> Encode(ReadOnlyMemory<byte> payload) {
        if (payload.Length > MaxPayloadBytes) {
            throw new InvalidDataException("The AHP message exceeds the relay payload limit.");
        }
        using var document = JsonDocument.Parse(payload);
        var single = Envelope(document.RootElement);
        if (single.Length <= MaxSingleEnvelopeBytes) {
            return [BinaryData.FromBytes(single)];
        }

        var groupId = Guid.NewGuid().ToString();
        var total = (payload.Length + ChunkBytes - 1) / ChunkBytes;
        if (total > MaxSegments) {
            throw new InvalidDataException("The AHP message requires too many relay chunks.");
        }
        var chunks = new BinaryData[total];
        for (var sequence = 0; sequence < total; sequence++) {
            var start = sequence * ChunkBytes;
            var length = Math.Min(ChunkBytes, payload.Length - start);
            chunks[sequence] = BinaryData.FromObjectAsJson(new {
                bytes = Convert.ToBase64String(payload.Span.Slice(start, length)),
                group_id = groupId,
                kind = "chunk",
                seq = sequence,
                total,
            });
        }
        return chunks;
    }

    public AhpEnvelopeResult Decode(BinaryData data, string group) {
        if (data.ToMemory().Length > MaxSingleEnvelopeBytes) {
            throw new InvalidDataException("The AHP relay envelope exceeds the frame limit.");
        }
        SweepExpired();
        using var document = JsonDocument.Parse(data.ToMemory());
        var root = document.RootElement;
        if (root.ValueKind != JsonValueKind.Object || !root.TryGetProperty("kind", out var kind)
            || kind.ValueKind != JsonValueKind.String) {
            throw new InvalidDataException("The AHP relay envelope has no kind.");
        }
        var generation = Integer(root, "generation", required: false, minimum: 1);
        return kind.GetString() switch {
            "batch" => Batch(root, generation),
            "capabilities" => new(AhpEnvelopeKind.Capabilities, [], generation),
            "chunk" => Chunk(root, group, generation),
            "closed" => new(AhpEnvelopeKind.Closed, [], generation),
            "message" => Message(root, generation),
            _ => throw new InvalidDataException("The AHP relay envelope has an unsupported kind."),
        };
    }

    private static AhpEnvelopeResult Batch(JsonElement root, long? generation) {
        if (!root.TryGetProperty("items", out var items) || items.ValueKind != JsonValueKind.Array
            || items.GetArrayLength() is < 1 or > 256) {
            throw new InvalidDataException("The AHP relay batch is invalid.");
        }
        return new(AhpEnvelopeKind.Batch,
            items.EnumerateArray().Select(item => Encoding.UTF8.GetBytes(item.GetRawText())).ToArray(),
            generation);
    }

    private AhpEnvelopeResult Chunk(JsonElement root, string group, long? generation) {
        var groupId = String(root, "group_id");
        var sequence = checked((int)Integer(root, "seq", required: true, minimum: 0)!.Value);
        var total = checked((int)Integer(root, "total", required: true, minimum: 1)!.Value);
        if (total is < 1 or > MaxSegments || sequence < 0 || sequence >= total) {
            throw new InvalidDataException("The AHP relay chunk metadata is invalid.");
        }
        byte[] bytes;
        try {
            var encoded = String(root, "bytes");
            bytes = Convert.FromBase64String(encoded);
            if (Convert.ToBase64String(bytes) != encoded) {
                throw new InvalidDataException("The AHP relay chunk is not canonical base64.");
            }
        } catch (FormatException ex) {
            throw new InvalidDataException("The AHP relay chunk is not valid base64.", ex);
        }

        var key = $"{group}\0{generation}\0{groupId}";
        if (!assemblies.TryGetValue(key, out var assembly)) {
            if (assemblies.Count >= MaxAssemblies) {
                throw new InvalidDataException("Too many AHP relay messages are awaiting reassembly.");
            }
            assembly = new Assembly(total);
            assemblies.Add(key, assembly);
        }
        if (assembly.Total != total || !assembly.Segments.TryAdd(sequence, bytes)) {
            assemblies.Remove(key);
            throw new InvalidDataException("The AHP relay sent conflicting chunk metadata.");
        }
        assembly.Bytes += bytes.Length;
        if (assembly.Bytes > MaxPayloadBytes) {
            assemblies.Remove(key);
            throw new InvalidDataException("The reassembled AHP message exceeds the payload limit.");
        }
        if (assembly.Segments.Count != total) {
            return new(AhpEnvelopeKind.Pending, [], generation);
        }

        var buffer = new ArrayBufferWriter<byte>(assembly.Bytes);
        for (var index = 0; index < total; index++) {
            if (!assembly.Segments.TryGetValue(index, out var segment)) {
                assemblies.Remove(key);
                throw new InvalidDataException("The AHP relay message is missing a chunk.");
            }
            buffer.Write(segment);
        }
        assemblies.Remove(key);
        try {
            using var parsed = JsonDocument.Parse(buffer.WrittenMemory);
        } catch (JsonException ex) {
            throw new InvalidDataException("The reassembled AHP message is not valid JSON.", ex);
        }
        return new(AhpEnvelopeKind.Payload, [buffer.WrittenMemory.ToArray()], generation);
    }

    private static byte[] Envelope(JsonElement payload) {
        var buffer = new ArrayBufferWriter<byte>();
        using var writer = new Utf8JsonWriter(buffer);
        writer.WriteStartObject();
        writer.WriteString("kind", "message");
        writer.WritePropertyName("data");
        payload.WriteTo(writer);
        writer.WriteEndObject();
        writer.Flush();
        return buffer.WrittenMemory.ToArray();
    }

    private static long? Integer(JsonElement value, string name, bool required, long minimum) {
        if (!value.TryGetProperty(name, out var property)) {
            return required ? throw new InvalidDataException($"The AHP relay envelope has no {name}.") : null;
        }
        return property.ValueKind == JsonValueKind.Number
            && property.TryGetInt64(out var number) && number >= minimum
            ? number : throw new InvalidDataException($"The AHP relay envelope has an invalid {name}.");
    }

    private static AhpEnvelopeResult Message(JsonElement root, long? generation) {
        if (!root.TryGetProperty("data", out var payload)) {
            throw new InvalidDataException("The AHP relay message envelope has no data.");
        }
        return new(AhpEnvelopeKind.Payload, [Encoding.UTF8.GetBytes(payload.GetRawText())], generation);
    }

    private static string String(JsonElement value, string name) {
        if (!value.TryGetProperty(name, out var property) || property.ValueKind != JsonValueKind.String
            || string.IsNullOrWhiteSpace(property.GetString())) {
            throw new InvalidDataException($"The AHP relay envelope has an invalid {name}.");
        }
        return property.GetString()!;
    }

    private void SweepExpired() {
        var cutoff = DateTimeOffset.UtcNow.AddSeconds(-30);
        foreach (var key in assemblies.Where(value => value.Value.Started <= cutoff)
            .Select(value => value.Key).ToArray()) {
            assemblies.Remove(key);
        }
    }

    private sealed class Assembly(int total) {
        public int Bytes { get; set; }

        public Dictionary<int, byte[]> Segments { get; } = [];

        public DateTimeOffset Started { get; } = DateTimeOffset.UtcNow;

        public int Total { get; } = total;
    }
}
