@{
    ModuleVersion     = '0.1.0'
    GUID              = 'a3f2b8c1-4d5e-6f7a-8b9c-0d1e2f3a4b5c'
    Author            = 'Alok Nigam'
    Description       = 'Fuzzy directory predictor for cd/Set-Location commands'
    PowerShellVersion = '7.2'

    NestedModules     = @('PSDirectoryPredictor.dll')
    FunctionsToExport = @()
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags = @('PSEdition_Core', 'Predictor', 'Directory', 'Fuzzy')
        }
    }
}
