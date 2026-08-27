# commitlint

Commit messages in every repo are linted against [Conventional Commits](https://www.conventionalcommits.org/)
by [commitlint](https://commitlint.js.org/).

## How it's wired

- **Config**: [`commitlint.config.js`](./commitlint.config.js) — extends `@commitlint/config-conventional`; all
  active rules live there.
- **Deployment**: [`setup.ps1`](./setup.ps1) installs `@commitlint/cli` + `@commitlint/config-conventional` and
  symlinks the config and hook into `~/.config/git/`.
- **Enforcement**: [`hooks/commit-msg`](./hooks/commit-msg) runs `commitlint --edit` on every commit. Because
  `.gitconfig` sets `core.hooksPath = ~/.config/git/hooks`, the same config applies to **all** repositories.

## Commit format

```
type(scope)!: subject

body

footer
```

See [`commitlint.config.js`](./commitlint.config.js) for the enforced `type` list, casing, length limits, and other
rules.

## Allowing scopes (per repository)

Scope is **optional**, but when present it must be allowlisted. The allowlist is **repo-specific**: the shared config
reads a `.commitlint-scopes.json` from the repository root at lint time.

To restrict scopes in a repo, add `.commitlint-scopes.json` at its root and commit it — a flat JSON array of
lower-case scope strings (lower-case is required by the `scope-case` rule):

```json
["api", "auth", "ci", "db", "deps", "ui"]
```

- File present → scope is optional, but any scope used must be in the list.
- File missing, empty array, or malformed → any scope is allowed.
