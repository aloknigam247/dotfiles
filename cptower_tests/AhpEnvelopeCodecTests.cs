using System.Text;
using System.Text.Json;
using CpTower;
using Xunit;

namespace CpTower.Tests;

public sealed class AhpEnvelopeCodecTests {
    [Fact]
    public void EncodesAndDecodesASmallMessage() {
        var codec = new AhpEnvelopeCodec();
        var payload = Encoding.UTF8.GetBytes("""{"id":1,"jsonrpc":"2.0","method":"ping"}""");

        var envelope = Assert.Single(codec.Encode(payload));
        var result = codec.Decode(envelope, "to-client");

        Assert.Equal(AhpEnvelopeKind.Payload, result.Kind);
        Assert.Equal(payload, Assert.Single(result.Payloads));
    }

    [Fact]
    public void ReassemblesLargeChunksDeliveredOutOfOrder() {
        var codec = new AhpEnvelopeCodec();
        var text = new string('x', 1_000_000);
        var payload = JsonSerializer.SerializeToUtf8Bytes(new { text });

        var envelopes = codec.Encode(payload);
        Assert.True(envelopes.Count > 1);
        AhpEnvelopeResult result = default;
        foreach (var envelope in envelopes.Reverse()) {
            result = codec.Decode(envelope, "to-client");
        }

        Assert.Equal(AhpEnvelopeKind.Payload, result.Kind);
        Assert.Equal(payload, Assert.Single(result.Payloads));
    }
}
