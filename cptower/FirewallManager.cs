using System.Diagnostics;

namespace CpTower;

/// <summary>
/// Ensures a single inbound firewall rule for the external port exists so the phone can reach cptower
/// on the LAN. Adding a rule requires elevation, so when the rule is missing the process relaunches
/// itself elevated once (a single UAC prompt) to install it — no manual netsh steps on a new machine.
/// </summary>
internal static class FirewallManager
{
    private const string RuleName = "cptower";

    /// <summary>Adds the inbound allow rule. Must run elevated. Invoked via the --install-firewall path.</summary>
    public static int AddRule(int port)
    {
        return RunNetsh(
            $"advfirewall firewall add rule name=\"{RuleName}\" dir=in action=allow " +
            $"protocol=TCP localport={port} profile=any");
    }

    /// <summary>Ensures the rule exists, self-elevating once if needed. Best-effort; never fatal.</summary>
    public static void Ensure(int port, ILogger log)
    {
        try
        {
            if (RuleExists())
            {
                return;
            }

            log.LogInformation("firewall rule '{Rule}' missing; requesting elevation to add it", RuleName);
            var exe = Environment.ProcessPath!;
            var psi = new ProcessStartInfo
            {
                FileName = exe,
                Arguments = $"--install-firewall --port {port}",
                UseShellExecute = true,
                Verb = "runas",
            };
            using var proc = Process.Start(psi);
            proc?.WaitForExit();

            if (RuleExists())
            {
                log.LogInformation("firewall rule '{Rule}' installed", RuleName);
            }
            else
            {
                log.LogWarning("firewall rule '{Rule}' was not installed (elevation declined?)", RuleName);
            }
        }
        catch (Exception ex)
        {
            log.LogWarning(ex, "could not ensure firewall rule");
        }
    }

    private static bool RuleExists() =>
        RunNetsh($"advfirewall firewall show rule name=\"{RuleName}\"") == 0;

    private static int RunNetsh(string args)
    {
        var psi = new ProcessStartInfo
        {
            FileName = "netsh",
            Arguments = args,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true,
        };
        using var proc = Process.Start(psi);
        if (proc is null)
        {
            return -1;
        }

        proc.StandardOutput.ReadToEnd();
        proc.StandardError.ReadToEnd();
        proc.WaitForExit();
        return proc.ExitCode;
    }
}
