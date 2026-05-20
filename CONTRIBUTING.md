# Contributing to FlakeOS

## Branch Strategy

- `main` is the stable branch. Direct commits and pushes to main are forbidden.
- `alpha` is the development branch. All changes go through PRs from alpha to main.
- Every change must be submitted as a pull request on GitHub.
- All CI jobs must pass before merge.

## Commit Convention

Every commit must follow [conventional commits](https://www.conventionalcommits.org/):

```
type(scope): description
```

Valid types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `ci`, `style`, `perf`.

The body must be empty for squash merges.

## Merge Rules

- Merges use squash strategy.
- Merge commits must have an empty body.
- Merge commits must **not** include the pull request number in the title.
- When using `gh pr merge --squash`, pass `--title "type(scope): description"` to prevent `(#n)` from being appended.

## Quality Gates

Before merge, all checks must pass:

- `statix check src` -- Nix linting
- `deadnix src` -- dead code detection
- `nixpkgs-fmt --check src` -- formatting
- `nix-instantiate --eval --strict tests/default.nix` -- library tests
- `nix-instantiate --eval --strict tests/modules.nix` -- module integration tests

## No Hardcoding

Usernames, hostnames, paths, IPs, ports, UUIDs, CPU, GPU, and RAM must never be hardcoded. Use options with `lib.mkDefault` and `lib.mkIf`.

## No Comments in Nix Files

Inline comments, block comments, and multi-line comments are forbidden in Nix files. Documentation belongs in AGENTS.md and docs/.

## Shell Scripts

Shell scripts must be separate files in `scripts/`, referenced via `pkgs.writeShellScriptBin` and `builtins.readFile`. No inline shell in Nix.
