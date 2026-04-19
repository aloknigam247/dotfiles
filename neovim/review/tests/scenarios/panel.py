"""Panel scenario: open panel at a comment, verify content + close."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from harness import Harness, FIXTURE


def main():
    h = Harness().start()
    try:
        h.setup_review(FIXTURE)
        h.exec_lua('require("review").load("file")')
        h.cmd("edit neovim/review/lua/review/init.lua")
        h.exec_lua('require("review").render(0)')
        h.wait(50)

        # Place cursor on c2 (line 45) which has a thread of 2 messages
        h.nvim.api.win_set_cursor(0, [45, 0])

        # Open panel
        h.exec_lua('require("review").cmd("panel", {})')
        h.wait(50)

        floats = h.floats()
        titled = [f for f in floats if f["title"]]
        assert len(titled) == 1, f"expected 1 titled float, got {len(titled)}"
        title_text = h.title_text(titled[0])
        assert "Bug" in title_text, f"title should contain category 'Bug': {title_text!r}"
        assert "HIGH" in title_text, f"title should contain severity 'HIGH': {title_text!r}"
        assert "pending" in title_text, f"title should show status 'pending': {title_text!r}"
        print(f"[OK] panel opened with title: {title_text!r}")

        # Buffer content includes thread messages
        panel_buf = titled[0]["buf"]
        lines = h.buf_lines(panel_buf)
        body = "\n".join(lines)
        assert "apply_highlights" in body, "panel should show comment body"
        assert "Can you suggest" in body, "panel should show first thread message"
        assert "Default to" in body, "panel should show second thread message"
        assert "Reply" in body, "panel should show reply prompt"
        print("[OK] panel shows comment body + thread + reply prompt")

        # Cursor should be in input region (clamped)
        cur_row = h.nvim.api.win_get_cursor(titled[0]["win"])[0]
        # Find the "Reply" line; cursor should be after it
        reply_line_idx = None
        for i, line in enumerate(lines):
            if line.startswith("Reply"):
                reply_line_idx = i + 1  # 1-based
                break
        assert reply_line_idx is not None, "reply prompt line not found"
        assert cur_row > reply_line_idx, f"cursor at {cur_row}, expected > {reply_line_idx}"
        print(f"[OK] cursor in input region (line {cur_row} > reply at {reply_line_idx})")

        # Close via <Esc> keymap
        # Switch focus into the panel buffer first
        h.nvim.api.set_current_win(titled[0]["win"])
        h.invoke_keymap("<Esc>")
        h.wait(50)

        floats_after = [f for f in h.floats() if f["title"]]
        assert len(floats_after) == 0, f"panel should be closed, found {len(floats_after)}"
        print("[OK] panel closes on <Esc>")

        print("\npanel scenario passed")
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


if __name__ == "__main__":
    main()
