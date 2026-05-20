# FLAKEOS NixOS

FLAKEOS is a modular immutable NixOS configuration framework built on Zero Hardcoding Zero Comments and Zero Inline Shell principles. Every value is parameterized through Nix options. All technical documentation lives in AGENTS.md. All shell scripts are standalone files in scripts referenced via builtins.readFile.

The framework includes a Spring style dependency injection and circuit breaker library for systemd services a MicroVM container engine with instance pool orchestration KDE Plasma 6 desktop with custom FlakeOS layout ZFS filesystem with impermanence and a layered security model with NFTables kernel hardening and SSH hardening.

## Quick Start

Set hostname and username in src/hosts/target-host/meta.nix. Run nixos-install flake hash target-host. Set a password and reboot. For ISO generation run nix build hash packages.x86_64-linux.iso-minimal for headless or nix build hash packages.x86_64-linux.iso-graphical for desktop.

## Prerequisites

Nix package manager with flakes enabled.

## Project Structure

src/hosts contains per machine configurations with meta.nix for system hardware profile hostname and username. src/modules contains categorized modules for core filesystem security containers desktop hardware and network. src/profiles defines use case profiles like workstation developer server and minimal. lib contains pure Nix libraries including hardware detection and the Spring framework.

## License

MIT
