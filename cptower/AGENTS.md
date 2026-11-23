# cptower navigation

## Layout

- [cptower_tests.csproj](../cptower_tests/cptower_tests.csproj): sibling xUnit test project.
- [dist/cptower.exe](dist/cptower.exe): tracked executable used by `Start-CpTower` in
  [powershell/profile.ps1](../powershell/profile.ps1).
- [README.md file map](README.md#files): responsibilities of the flat C# source files beside the project.

## Build and run

From this directory:

```ps1
dotnet build .\cptower.csproj -c Release
```

Use [README run instructions](README.md#run) for prerequisites, launch options, and publishing. Read the
[network security boundary](README.md#security) before launching the service.
