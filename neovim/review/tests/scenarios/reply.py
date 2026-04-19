"""Reply scenario: post a reply via the file provider, verify thread + persistence."""
import json
import shutil
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from harness import Harness, FIXTURE


def main():
    # Copy fixture to a temp file so we can mutate without polluting the repo
    tmp = Path(tempfile.mkdtemp()) / "comments.json"
    shutil.copy(FIXTURE, tmp)

    h = Harness().start()
    try:
        h.setup_review(tmp)
        h.exec_lua('require("review").load("file")')
        h.cmd("edit neovim/review/lua/review/init.lua")
        h.exec_lua('require("review").render(0)')
        h.wait(50)

        # Open panel for c2 (cursor on line 45)
        h.nvim.api.win_set_cursor(0, [45, 0])
        h.exec_lua('require("review").cmd("panel", {})')
        h.wait(50)

        floats = [f for f in h.floats() if f["title"]]
        assert len(floats) == 1, f"expected 1 panel, got {len(floats)}"
        panel_buf = floats[0]["buf"]
        panel_win = floats[0]["win"]

        # Find input region (lines after "Reply...")
        lines = h.buf_lines(panel_buf)
        reply_idx = next(i for i, l in enumerate(lines) if l.startswith("Reply"))

        # Write reply text into the input region
        h.nvim.api.buf_set_lines(panel_buf, reply_idx + 1, -1, False, ["This is my reply"])

        # Submit via panel.submit_reply() (avoid feedkeys flakiness for <C-s>)
        h.exec_lua('require("review.panel").submit_reply()')
        h.wait(50)

        # Thread now has 3 messages (2 original + 1 new)
        thread = h.lua('require("review.state").get("c2").thread')
        assert len(thread) == 3, f"expected 3 thread messages, got {len(thread)}"
        assert thread[2]["body"] == "This is my reply", f"wrong body: {thread[2]}"
        assert thread[2]["author"] == "you", f"wrong author: {thread[2]}"
        print(f"[OK] reply added; thread now has {len(thread)} messages")

        # Persisted to disk
        with open(tmp) as f:
            data = json.load(f)
        c2 = next(c for c in data if c["id"] == "c2")
        assert len(c2["thread"]) == 3, f"file thread length wrong: {len(c2['thread'])}"
        assert c2["thread"][2]["body"] == "This is my reply"
        print("[OK] reply persisted to file")

        # Panel re-rendered: input cleared
        lines_after = h.buf_lines(panel_buf)
        reply_idx_after = next(i for i, l in enumerate(lines_after) if l.startswith("Reply"))
        input_lines = lines_after[reply_idx_after + 1:]
        assert all(l == "" for l in input_lines), f"input not cleared: {input_lines!r}"
        print("[OK] input cleared after submit")

        # Reply text appears in re-rendered thread
        body = "\n".join(lines_after)
        assert "This is my reply" in body, "panel did not refresh with new reply"
        print("[OK] panel refreshed with new reply visible")

        print("\nreply scenario passed")
    except AssertionError as e:
        print(f"\nFAIL: {e}")
        h.dump("failure state")
        sys.exit(1)
    except Exception as e:
        print(f"\nERROR: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(2)
    finally:
        h.close()
        shutil.rmtree(tmp.parent, ignore_errors=True)


if __name__ == "__main__":
    main()
