# FlakeOS

FlakeOS is a modular, immutable NixOS configuration framework built on three principles: Zero Hardcoding, Zero Comments, and Zero Inline Shell. Every value is parameterized through Nix options. All technical documentation lives in AGENTS.md. All shell scripts are standalone files in the `scripts` directory, referenced via `builtins.readFile`.

The framework includes a Spring-style dependency injection and circuit breaker library for systemd services, a MicroVM container engine with instance pool orchestration, KDE Plasma 6 desktop with custom FlakeOS layout, ZFS filesystem with impermanence, and a layered security model with NFTables, kernel hardening, and SSH hardening.

## Quick Start

Set the hostname and username in `src/hosts/target-host/meta.nix`, then run:

```
nixos-install --flake github:flakeos/os#target-host
```

Set a password and reboot. For ISO generation:

- Headless: `nix build .#packages.x86_64-linux.iso-minimal`
- Desktop: `nix build .#packages.x86_64-linux.iso-graphical`

## Prerequisites

- Nix package manager with flakes enabled
- For ISO build: approximately 10 GB of free disk space
- For installation: a target machine with UEFI boot support

## Project Structure

The repository is organized into functional directories. The `src/hosts` directory contains per-machine configurations with `meta.nix` files for system architecture, hardware profile, hostname, and username. The `src/module` directory contains categorized modules for core system, filesystem, security, containers, desktop, hardware, and network. The `src/profiles` directory defines use case profiles such as workstation, developer, server, and minimal. The `lib` directory contains pure Nix libraries including hardware detection and the Spring framework. The `scripts` directory holds standalone shell scripts. The `config` directory holds external configuration files referenced by modules.

## License

MIT
