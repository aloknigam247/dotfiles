"""Smoke scenario: load file provider, verify diagnostics + bg + state populated."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from harness import Harness, FIXTURE


def main():
    h = Harness().start()
    try:
        # Plugin loads
        ok = h.lua('pcall(require, "review")')
        assert ok, "review module failed to load"
        print("[OK] review module loaded")

        # Setup with the file provider
        h.setup_review(FIXTURE)
        print("[OK] setup() registered file provider")

        # Load comments
        h.exec_lua('require("review").load("file")')
        h.wait(50)

        # State populated
        comments = h.lua('require("review.state").all()')
        assert isinstance(comments, dict) and len(comments) == 4, \
            f"expected 4 comments, got {comments and len(comments)}"
        print(f"[OK] state has {len(comments)} comments")

        files = h.lua('require("review.state").files()')
        assert len(files) == 3, f"expected 3 files, got {len(files)}: {files}"
        print(f"[OK] {len(files)} files indexed")

        # Open a reviewed file
        target = "neovim/review/lua/review/init.lua"
        h.cmd(f"edit {target}")
        h.wait(50)
        h.exec_lua('require("review").render(0)')
        h.wait(50)

        # Two comments are on init.lua (c1, c2)
        diags = h.diagnostics()
        assert len(diags) == 2, f"expected 2 diagnostics on init.lua, got {len(diags)}"
        print(f"[OK] {len(diags)} diagnostics on init.lua")

        # Severity mapping: medium → WARN(2), high → ERROR(1)
        sevs = sorted(d["severity"] for d in diags)
        assert sevs == [1, 2], f"expected [WARN=2, ERROR=1], got {sevs}"
        print(f"[OK] severities map correctly: {sevs}")

        # BG extmarks present
        marks = h.bg_extmarks()
        assert len(marks) == 2, f"expected 2 bg extmarks, got {len(marks)}"
        print(f"[OK] {len(marks)} bg extmarks")

        # Highlight groups defined
        for name in ["ReviewBgPending", "ReviewBgAccepted", "ReviewBgRejected",
                     "ReviewBorderPending", "ReviewCategory"]:
            hl = h.hl(name)
            assert hl.get("fg") is not None or hl.get("bg") is not None, f"{name} missing"
        print("[OK] highlight groups present")

        print("\nsmoke test passed")
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
