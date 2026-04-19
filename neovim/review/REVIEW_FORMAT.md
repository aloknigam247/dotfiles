# Review JSON Format

A schema for code review comments consumed by `review.nvim`'s file provider.

## File Structure

A JSON array of comment objects. The plugin reads this file via the `file` provider and writes it back when statuses change or replies are posted.

```json
[
  {
    "id": "c1",
    "file": "src/main.py",
    "line": 42,
    "end_line": 44,
    "category": "Security",
    "severity": "high",
    "author": "AI Agent",
    "timestamp": "2026-04-19T12:00:00Z",
    "body": "SQL injection vulnerability. Use parameterized queries.",
    "status": "pending",
    "thread": [
      {
        "id": "m1",
        "author": "you",
        "timestamp": "2026-04-19T12:05:00Z",
        "body": "How should I refactor this safely?"
      }
    ]
  }
]
```

## Comment Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | string | no | `file:line:N` | Stable unique id per comment |
| `file` | string | yes | — | Relative path from project root, forward slashes |
| `line` | integer | yes | — | 1-based start line |
| `col` | integer | no | 1 | 1-based start column |
| `end_line` | integer | no | `line` | 1-based end line |
| `end_col` | integer | no | end-of-line | 1-based end column (`0` = end of line) |
| `category` | string | no | "Comment" | Free-form ("Bug", "Security", "Style", ...) |
| `severity` | string | yes | "info" | One of: `high`, `medium`, `low`, `info` |
| `author` | string | no | "reviewer" | Comment author |
| `timestamp` | string | no | — | ISO-8601 timestamp |
| `body` | string | yes | — | Comment text (may contain `\n`) |
| `status` | string | no | "pending" | One of: `pending`, `accepted`, `rejected` |
| `thread` | array | no | `[]` | Reply messages |

## Message Fields (thread items)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique within thread |
| `author` | string | yes | Sender ("you", "AI Agent", etc.) |
| `timestamp` | string | no | ISO-8601 |
| `body` | string | yes | Message text |

## Severity Mapping (visual)

| Severity | Diagnostic | Sign Color |
|----------|-----------|------------|
| `high` | ERROR | red |
| `medium` | WARN | yellow |
| `low` | INFO | blue |
| `info` | HINT | green |

## Status Mapping (visual)

The status sets the **range background tint** independently of severity:

| Status | Background |
|--------|-----------|
| `pending` | blue |
| `accepted` | green |
| `rejected` | red |

## Instructions for an AI Agent

When asked to perform a code review, output a single JSON file matching this schema:

1. Set `severity` based on impact: `high` for bugs/security, `medium` for performance/reliability, `low` for style, `info` for praise/observations.
2. Always include `body` (the review text) and `severity`.
3. Use `line`/`end_line` to span multiple lines if the comment refers to a block.
4. Set `status` to `"pending"` initially. Leave `thread` as `[]`.
5. Use a stable `id` if you want updates to merge correctly across runs (e.g., a hash of `file + line + body`).

Example prompt:

> Review the following files. Output a JSON file matching the schema in REVIEW_FORMAT.md. Use relative paths from the project root.
