"""Navigation scenario: ]c / [c jump between comments and update active id."""
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

        # Two comments on init.lua: c1 at line 10, c2 at line 45
        # Start at line 1
        h.nvim.api.win_set_cursor(0, [1, 0])

        # ]c -> c1 (line 10)
        h.exec_lua('require("review.nav").next()')
        h.wait(20)
        cur = h.cursor()
        assert cur[0] == 10, f"expected cursor on line 10 after ]c, got {cur[0]}"
        active = h.lua('require("review.state").active_id()')
        assert active == "c1", f"expected active=c1, got {active}"
        print(f"[OK] ]c jumped to c1 (line {cur[0]})")

        # ]c -> c2 (line 45)
        h.exec_lua('require("review.nav").next()')
        h.wait(20)
        cur = h.cursor()
        assert cur[0] == 45, f"expected cursor on line 45 after ]c, got {cur[0]}"
        active = h.lua('require("review.state").active_id()')
        assert active == "c2", f"expected active=c2, got {active}"
        print(f"[OK] ]c jumped to c2 (line {cur[0]})")

        # ]c wraps -> c1
        h.exec_lua('require("review.nav").next()')
        h.wait(20)
        cur = h.cursor()
        assert cur[0] == 10, f"expected wrap to line 10, got {cur[0]}"
        print(f"[OK] ]c wraps around to c1 (line {cur[0]})")

        # [c -> c2
        h.exec_lua('require("review.nav").prev()')
        h.wait(20)
        cur = h.cursor()
        assert cur[0] == 45, f"expected [c -> line 45, got {cur[0]}"
        print(f"[OK] [c jumped back to c2 (line {cur[0]})")

        print("\nnavigation scenario passed")
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
