# cptower navigation

## Layout

- [cptower.csproj](cptower.csproj): web application target and dependencies.
- [cptower_tests.csproj](../cptower_tests/cptower_tests.csproj): sibling xUnit test project.
- [dist/cptower.exe](dist/cptower.exe): tracked executable used by `Start-CpTower` in
  [powershell/profile.ps1](../powershell/profile.ps1).
- [Program.cs](Program.cs): argument parsing, dependency registration, Kestrel startup, and route wiring.
- [README.md file map](README.md#files): responsibilities of the flat C# source files beside the project.

[.gitignore](.gitignore) excludes `bin/` and `obj/`; do not treat `dist/` as ignored build output.

## Request flow

`GET /hosts` calls `DiscoveryService.RefreshAsync`, then returns the `HostRegistry` snapshot. Follow
[DiscoveryService.cs](DiscoveryService.cs) for direct-host reconciliation and Mission Control discovery dispatch.
Discovery is request-driven, not a background polling service.

The WebSocket route resolves a discovered host from the registry and delegates to
[AhpRelay.cs](AhpRelay.cs). [AhpConnection.cs](AhpConnection.cs) selects the direct or Mission Control transport.
For authentication, catalog fields, and shared-host configuration, use the [README](README.md).

## Build and run

From this directory:

```ps1
dotnet build .\cptower.csproj -c Release
```

Use [README run instructions](README.md#run) for prerequisites, launch options, and publishing. Read the
[network security boundary](README.md#security) before launching the service.
