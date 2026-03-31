import asyncio
import os
import re
import uuid

from mcp.server.fastmcp import Context, FastMCP
from mcp.server.fastmcp.exceptions import ToolError

mcp = FastMCP("native-tools")

ANSI_ESCAPE = re.compile(r"\x1b(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")
MAX_OUTPUT = 30000


def strip_ansi(text: str) -> str:
    return ANSI_ESCAPE.sub("", text)


def read_file_safe(path: str) -> str | None:
    try:
        with open(path, "r", encoding="utf-8-sig", errors="replace") as f:
            return f.read()
    except (PermissionError, OSError):
        return None


def truncate(text: str) -> str:
    if len(text) > MAX_OUTPUT:
        return text[:MAX_OUTPUT] + "\n... (output truncated)"
    return text


@mcp.tool()
async def pwsh(command: str, ctx: Context, working_directory: str = "") -> str:
    """Run a PowerShell 7 (pwsh) command in a new Windows Terminal tab.

    Output is streamed back as it becomes available.
    The command runs visibly in a new terminal tab with colored output.

    Args:
        command: The PowerShell command to execute.
        working_directory: Optional working directory for the command.
    """
    guid = str(uuid.uuid4())
    temp_dir = os.environ.get("TEMP", os.environ.get("TMP", "."))
    base = os.path.join(temp_dir, f"mcp-pwsh-{guid}")
    cmd_file = f"{base}.cmd.txt"
    stdout_file = f"{base}.stdout"
    stderr_file = f"{base}.stderr"
    sentinel_file = f"{base}.done"
    runner_script = os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "runner.ps1"
    )

    try:
        # Write command to temp file to avoid quoting issues
        with open(cmd_file, "w", encoding="utf-8") as f:
            f.write(command)

        # Launch in new Windows Terminal tab
        title = (command[:40] + "\u2026") if len(command) > 40 else command
        title = title.replace('"', "'")
        wt_cmd = (
            f'wt -w 0 new-tab --title "{title}" -- '
            f"pwsh -NoProfile -ExecutionPolicy Bypass "
            f'-File "{runner_script}" '
            f'-CommandFile "{cmd_file}" '
            f'-StdoutFile "{stdout_file}" '
            f'-StderrFile "{stderr_file}" '
            f'-SentinelFile "{sentinel_file}" '
            f'-WorkingDirectory "{working_directory or os.getcwd()}"'
        )
        await asyncio.create_subprocess_shell(wt_cmd)

        # Poll and stream output
        last_out_pos = 0
        last_err_pos = 0
        timeout = 300
        elapsed = 0.0
        interval = 0.3

        while elapsed < timeout:
            if os.path.exists(sentinel_file):
                break

            out = read_file_safe(stdout_file)
            if out and len(out) > last_out_pos:
                new_text = strip_ansi(out[last_out_pos:])
                last_out_pos = len(out)
                if new_text.strip():
                    await ctx.info(new_text.rstrip())

            err = read_file_safe(stderr_file)
            if err and len(err) > last_err_pos:
                new_text = strip_ansi(err[last_err_pos:])
                last_err_pos = len(err)
                if new_text.strip():
                    await ctx.warning(new_text.rstrip())

            await asyncio.sleep(interval)
            elapsed += interval
        else:
            raise ToolError("Command timed out after 5 minutes")

        # Final read after completion
        await asyncio.sleep(0.2)
        stdout = strip_ansi(read_file_safe(stdout_file) or "").rstrip()
        stderr = strip_ansi(read_file_safe(stderr_file) or "").rstrip()
        exit_code_str = (read_file_safe(sentinel_file) or "1").strip()
        try:
            exit_code = int(exit_code_str)
        except ValueError:
            exit_code = 1

        stdout = truncate(stdout)
        stderr = truncate(stderr)

        # Non-zero exit → error result (matches Bash tool <error> behavior)
        if exit_code != 0:
            parts = []
            if stdout:
                parts.append(stdout)
            if stderr:
                parts.append(stderr)
            output = "\n".join(parts)
            raise ToolError(
                f"Exit code {exit_code}\n{output}" if output else f"Exit code {exit_code}"
            )

        # Success → plain text result (matches Bash tool <output> behavior)
        output = stdout
        if stderr:
            output = f"{output}\n{stderr}" if output else stderr
        return output if output else "(completed with no output)"

    except ToolError:
        raise
    except Exception as e:
        raise ToolError(str(e))
    finally:
        for path in (cmd_file, stdout_file, stderr_file, sentinel_file):
            try:
                if os.path.exists(path):
                    os.remove(path)
            except OSError:
                pass


if __name__ == "__main__":
    mcp.run(transport="stdio")
