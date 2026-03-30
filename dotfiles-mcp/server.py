import asyncio

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("dotfiles-mcp")


@mcp.tool()
async def run_powershell(command: str) -> str:
    """Run a PowerShell 7 (pwsh) command and return its output.

    Args:
        command: The PowerShell command to execute.
    """
    try:
        process = await asyncio.create_subprocess_exec(
            "pwsh", "-NoProfile", "-NonInteractive", "-Command", command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        stdout, stderr = await asyncio.wait_for(process.communicate(), timeout=60)

        output_parts = []
        if stdout:
            output_parts.append(stdout.decode("utf-8", errors="replace"))
        if stderr:
            output_parts.append(f"STDERR:\n{stderr.decode('utf-8', errors='replace')}")
        if process.returncode != 0:
            output_parts.append(f"Exit code: {process.returncode}")

        return "\n".join(output_parts) if output_parts else "(no output)"
    except asyncio.TimeoutError:
        return "Error: command timed out after 60 seconds."
    except FileNotFoundError:
        return "Error: pwsh not found. Is PowerShell 7 installed?"


if __name__ == "__main__":
    mcp.run(transport="stdio")
