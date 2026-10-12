using System.Management.Automation;
using System.Management.Automation.Subsystem;

namespace PSDirectoryPredictor;

public class Init : IModuleAssemblyInitializer, IModuleAssemblyCleanup {
    internal static DirectoryPredictor? DirectoryInstance;
    internal static FuzzyHistoryPredictor? HistoryInstance;

    public void OnImport() {
        DirectoryInstance = new DirectoryPredictor();
        SubsystemManager.RegisterSubsystem(SubsystemKind.CommandPredictor, DirectoryInstance);

        HistoryInstance = new FuzzyHistoryPredictor();
        SubsystemManager.RegisterSubsystem(SubsystemKind.CommandPredictor, HistoryInstance);
    }

    public void OnRemove(PSModuleInfo module) {
        if (DirectoryInstance is not null) {
            SubsystemManager.UnregisterSubsystem(SubsystemKind.CommandPredictor, DirectoryInstance.Id);
            DirectoryInstance.Dispose();
            DirectoryInstance = null;
        }
        if (HistoryInstance is not null) {
            SubsystemManager.UnregisterSubsystem(SubsystemKind.CommandPredictor, HistoryInstance.Id);
            HistoryInstance.Dispose();
            HistoryInstance = null;
        }
    }
}
