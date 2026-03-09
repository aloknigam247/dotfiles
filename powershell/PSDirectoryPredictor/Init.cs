using System.Management.Automation;
using System.Management.Automation.Subsystem;

namespace PSDirectoryPredictor;

public class Init : IModuleAssemblyInitializer, IModuleAssemblyCleanup
{
    internal static DirectoryPredictor? Instance;

    public void OnImport()
    {
        Instance = new DirectoryPredictor();
        SubsystemManager.RegisterSubsystem(SubsystemKind.CommandPredictor, Instance);
    }

    public void OnRemove(PSModuleInfo module)
    {
        if (Instance is not null)
        {
            SubsystemManager.UnregisterSubsystem(SubsystemKind.CommandPredictor, Instance.Id);
            Instance.Dispose();
            Instance = null;
        }
    }
}
