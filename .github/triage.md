# dotfiles: repository triage policy

## Categories

Choose exactly one primary category: `bug`, `chore`, `docs`, `feature`, `performance`, `refactor`, `tech-debt`.
For findings-only investigation, add `spike` alongside that category, usually `chore`; do not replace the primary
category with `spike`.

## Investigation

Use `.github\copilot-instructions.md` Project Structure and the relevant package's `setup.ps1` and local guidance.
Identify packages by their top-level directories. Anchor changes to setup variables, functions, config keys, and the
actual installation/linking path; check Windows/Linux applicability.

For package-manager or PowerShell-module changes, reference the corresponding section of that instruction file
instead of restating its wiring rules.

## Validation

Use the repository's documented local validation rather than inventing a unit-test or CI requirement.
State the exact relevant setup/profile-reload command, expected symlink or copied-file result, and a manual action
that exercises the changed configuration. Include the existing behavior that must remain intact.
