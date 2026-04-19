"""Status toggle scenario: accept/reject and revert; verify diagnostic + bg + persist."""
import json
import shutil
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from harness import Harness, FIXTURE


def main():
    tmp = Path(tempfile.mkdtemp()) / "comments.json"
    shutil.copy(FIXTURE, tmp)

    h = Harness().start()
    try:
        h.setup_review(tmp)
        h.exec_lua('require("review").load("file")')
        h.cmd("edit neovim/review/lua/review/init.lua")
        h.exec_lua('require("review").render(0)')
        h.wait(50)

        # Initial: c1 and c2 are pending → bg should be ReviewBgPending
        bg = h.bg_extmarks()
        assert len(bg) == 2, f"expected 2 bg extmarks, got {len(bg)}"
        # extmark detail tuple: [id, row, col, details]
        hl_groups = sorted(m[3]["hl_group"] for m in bg)
        assert hl_groups == ["ReviewBgPending", "ReviewBgPending"], f"initial bg: {hl_groups}"
        print("[OK] initial bg: both pending")

        # Cursor on c1 (line 10), accept via panel command
        h.nvim.api.win_set_cursor(0, [10, 0])
        h.exec_lua('require("review").cmd("accept", {})')
        h.wait(50)
        h.exec_lua('require("review.diagnostics").render(0)')
        h.wait(20)

        c1 = h.lua('require("review.state").get("c1")')
        assert c1["status"] == "accepted", f"c1 status: {c1['status']}"
        print("[OK] c1 status changed to accepted")

        bg = h.bg_extmarks()
        hl_groups = sorted(m[3]["hl_group"] for m in bg)
        assert "ReviewBgAccepted" in hl_groups, f"expected accepted bg, got {hl_groups}"
        print(f"[OK] bg reflects new status: {hl_groups}")

        # Persisted
        with open(tmp) as f:
            data = json.load(f)
        c1_disk = next(c for c in data if c["id"] == "c1")
        assert c1_disk["status"] == "accepted", f"disk: {c1_disk['status']}"
        print("[OK] status persisted to file")

        # Toggle: cursor on c2 (line 45), reject
        h.nvim.api.win_set_cursor(0, [45, 0])
        h.exec_lua('require("review").cmd("reject", {})')
        h.wait(50)
        h.exec_lua('require("review.diagnostics").render(0)')
        h.wait(20)

        c2 = h.lua('require("review.state").get("c2")')
        assert c2["status"] == "rejected", f"c2 status: {c2['status']}"
        print("[OK] c2 status changed to rejected")

        bg = h.bg_extmarks()
        hl_groups = sorted(m[3]["hl_group"] for m in bg)
        assert "ReviewBgAccepted" in hl_groups and "ReviewBgRejected" in hl_groups, \
            f"expected both accepted+rejected bgs, got {hl_groups}"
        print(f"[OK] bg shows mixed statuses: {hl_groups}")

        # Severity unchanged: c1 was medium → WARN(2), c2 was high → ERROR(1)
        diags = h.diagnostics()
        sevs = sorted(d["severity"] for d in diags)
        assert sevs == [1, 2], f"severities should be unchanged [1,2], got {sevs}"
        print(f"[OK] severities unchanged after status toggles: {sevs}")

        print("\nstatus_toggle scenario passed")
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
