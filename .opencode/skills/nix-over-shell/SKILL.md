---
name: nix-over-shell
description: Use ONLY when reviewing shell scripts or deciding whether logic should be Nix or shell — the default assumption is Nix, shell is only justified for runtime state, persistent loops, or hardware probing.
---

# Nix Over Shell

## Mandate

THE DEFAULT ASSUMPTION IS NIX. SHELL IS THE EXCEPTION.

Any shell script that COULD be Nix MUST be Nix. Shell is only justified when runtime state, persistent loops, or hardware probing make Nix provably impossible.

## Convert these to Nix

- Shell scripts that wrap a single command → Nix `serviceConfig` directives
- Shell scripts that only set environment variables and call one binary → Nix systemd `Config` directives
- Shell scripts that perform trivial argument forwarding → Nix
- Any script where the logic can be expressed as Nix option values

## Shell is acceptable for

- Reading runtime state (pool-manager.sh reads cgroup counters)
- Persistent event loops (orchestrator polls state)
- Hardware probing at runtime (cannot be known at build time)

## Shell script rules

1. File in `scripts/category/name.sh`, never inline in Nix strings
2. Shebang: `#!/usr/bin/env bash` with `set -euo pipefail`
3. References via `pkgs.writeShellScriptBin { name = ...; text = builtins.readFile ./path.sh; }`
4. Zero `${VAR:-default}` patterns — use `${VAR:?error}` instead
5. Every parameter must be validated

## Before writing shell, ask

- Can this be a Nix option value?
- Can this be a systemd `ExecStart` with arguments?
- Can this be a `serviceConfig` directive?
- Can this be a `boot.kernelParams` or `environment.etc`?

If yes to any, write Nix.
