# FLAKEOS NixOS Architecture Document

Version 2.1.0

## Introduction

FLAKEOS is a modular immutable NixOS configuration framework built on four pillars. Zero Hardcoding means every value is parameterized through Nix options. No usernames hostnames paths IPs or hardware identifiers are hardcoded. Host specific values are declared in meta.nix files and injected via specialArgs. Zero Comments means Nix files contain no comments. All technical documentation lives in AGENTS.md. User documentation lives in docs. This enforces self documenting code through meaningful identifier names and pure functional patterns. Zero Inline Shell means every shell script is stored as a standalone file in scripts and referenced via builtins.readFile. No script content appears inside Nix strings. Pure Functions means library functions in lib are pure with no side effects. Module evaluation is deterministic and idempotent.

## Repository Structure

The repository follows a strict directory layout enforced by the module loader and build system. The top level contains flake.nix as the entry point declaring inputs like nixpkgs nixos-hardware microvm sops-nix and nixos-generators and defining outputs for each discovered host plus ISO generation. configuration.nix is the module loader that auto scans src/module for category directories imports each category default.nix and loads the selected profile from src/profiles.

The source tree is organized as follows. src/hosts contains per machine configurations with each subdirectory named after the host containing meta.nix for system hardware profile hostname and username default.nix for host specific config and hardware.nix for generated hardware scan. src/profiles defines use case configurations including workstation with desktop KDE and FlakeOS layout developer with workstation plus dev tools server with headless and container orchestrator and minimal with headless minimal. src/module is organized by category with core for boot nix locale and sysctl filesystem for ZFS and impermanence security for firewall hardening and SSH containers for MicroVM host orchestrator and instance pool desktop for KDE minimal PipeWire and FlakeOS layout hardware for CPU GPU and platform and network for base and DNS.

src/guests defines MicroVM guest templates with sandbox.nix as a generic template and the example directory demonstrating a concrete instance definition with pool configuration. lib contains pure Nix library functions including hardware detection database Spring DI IoC framework with circuit breaker and the library aggregator. config holds external configuration files referenced by modules such as desktop panel layouts NFTables rulesets and container bridge configuration. scripts holds standalone shell scripts organized by subsystem including spring services desktop initialization pool management and ISO build utilities. assets is reserved for static files like wallpapers themes fonts and icons. secrets is reserved for encrypted secrets via SOPS and age. tests contains pure Nix evaluation tests and a shell environment for linting with statix deadnix and nixpkgs-fmt. docs contains documentation in markdown format. .changelog contains per release changelog entries following conventional commits format.

## Core Design Principles

Single Responsibility means each Nix file has exactly one purpose. A file equals one module equals one function. No file mixes concerns. Auto Discovery means the configuration.nix module loader scans src/module at evaluation time. No manual imports are needed when adding new modules. Each category default.nix imports all submodules within that category.

Conditional Activation means modules are enabled or disabled via mkIf cfg.enable. The enable option is declared in the module options block. Profiles activate combinations of modules by setting these options to their preferred values. Idempotency means nixos-rebuild switch is idempotent. Running it twice produces the same result. No state is modified outside the Nix store. User state lives exclusively in persist and home. The root filesystem is ephemeral through impermanence.

Atomicity means every nixos-rebuild produces a new generation. The previous generation remains intact and selectable from the boot menu. Rollback uses nixos-rebuild switch rollback. ZFS snapshots are taken automatically before and after rebuild via sanoid. Parameterization means all configurable values use Nix options with mkOption. Default values use mkDefault so they can be overridden. Conditional values use mkIf. No literal values appear in configuration logic.

## Module System

Modules are organized into categories under src/module. Each category represents a subsystem of the operating system. The core category covers boot configuration with systemd-boot kernel parameters and initrd Nix daemon settings with auto-optimise garbage collection and substituters locale and timezone and sysctl kernel parameters. The filesystem category covers ZFS pool creation ARC tuning automatic trimming scrub scheduling sanoid snapshot retention disko partitioning and impermanence configuration with persistent directories and files.

The security category covers NFTables firewall with default drop policy kernel hardening through sysctl AppArmor enforcement with lockdown SSH server hardening with key only access rate limiting and minimal ciphers Fail2ban for brute force protection and audit logging. The containers category covers MicroVM host configuration with bridge networking orchestrator for managing guest lifecycles and instance pool for dynamic scaling of guest instances with cgroup v2 resource isolation.

The desktop category covers KDE Plasma 6 minimal installation PipeWire audio server and FlakeOS custom desktop layout with top bar dock global menu and cosmic dark theme. The hardware category covers CPU specific optimizations for Intel AMD and ARM GPU drivers and configuration for NVIDIA AMD and Intel and platform tuning for desktop laptop and server. The network category covers base network configuration and DNS resolver settings.

Each module defines an options block with an enable flag and all configurable parameters. The config block is wrapped in mkIf cfg.enable. Assertions validate parameter combinations at evaluation time. To create a new module you first create src/module/category/name.nix with options and config then update src/module/category/default.nix to import the new file then define options with mkOption and use mkIf for conditional config and finally use assertions to validate constraints.

## Host and Profile System

Each host is defined in src/hosts/hostname. The meta.nix file declares four attributes. system is the NixOS system architecture such as x86_64-linux. hardware is the hardware class such as desktop laptop or server. profile is the use case profile name such as workstation developer server or minimal. hostname is the machine hostname. username is the primary user name.

The flake.nix reads src/hosts to discover available hosts. It passes hostname and username from meta.nix as specialArgs to the NixOS configuration. This eliminates all hardcoded user and host references. Profiles in src/profiles define combinations of enabled modules. A profile sets flakeos options to mkDefault values establishing the baseline configuration for that use case. Profiles inherit from more basic profiles where applicable. The configuration.nix loads the profile specified in meta.nix using a dynamic import based on the profile attribute.

## Spring Framework

The Spring framework in lib/spring.nix provides dependency injection and circuit breaker patterns for systemd services. Bean definitions use the flakeos.spring.beans attribute set. Each bean specifies a class as a service type identifier for organizational purposes a deps list of bean names this bean depends on resources with resource limits for cgroup v2 isolation including cpu memory memoryMax pids ioRbps ioWbps and numa a healthcheck command that returns zero for healthy service dependsOn for systemd unit dependencies after for systemd unit ordering and restartPolicy for systemd restart policy.

The framework performs topological sort of bean dependencies at build time. Circular dependencies cause a build failure with a diagnostic message listing the cycle. The circuit breaker implements a three state machine. CLOSED is normal operation where requests pass through and failures increment a counter. OPEN is when the circuit is open requests are blocked and a timeout timer starts. HALF-OPEN is recovery test mode where limited requests are allowed through.

Circuit breaker transitions work as follows. CLOSED transitions to OPEN when failures reach the threshold which defaults to 5. OPEN transitions to HALF-OPEN after the timeout which defaults to 30 seconds. HALF-OPEN transitions to CLOSED when successes reach the threshold which defaults to 2. HALF-OPEN transitions to OPEN on any failure in half-open state.

Cgroup v2 hierarchy is created under sys fs cgroup hostname bean name with cpu.max memory.max pids.max and io.max limits. OOM policy is set to kill for all Spring services. The health check flow executes the healthcheck command periodically. Success calls circuit_success which may transition to CLOSED. Failure calls circuit_trip which may transition to OPEN. When the circuit is OPEN the service exits with code 1.

## Security Architecture

Security is implemented in layers. Kernel hardening uses sysctl parameters to restrict kernel pointer access dmesg access performance events ptrace BPF kexec and SysRq. ASLR is set to maximum. Unprivileged BPF is disabled. BPF JIT is disabled.

The firewall uses NFTables with a default drop policy on the input chain. Only established and related connections loopback traffic rate limited ICMP and SSH from LAN addresses are accepted. The forward chain accepts established and related connections and traffic from the microvm bridge interface. The output chain has a default accept policy.

SSH is hardened with no root login no password authentication key only access rate limited authentication attempts limited sessions no TCP or agent forwarding and modern cipher suites including ChaCha20-Poly1305 and AES-256-GCM with ETM MACs. AppArmor is enforced with cache enabled. The apparmor-profiles package provides additional profiles. Lockdown is set to confidentiality. Fail2ban monitors SSH and HTTP services. Audit logging captures security relevant events.

## Filesystem Architecture

The filesystem uses ZFS as the primary filesystem with impermanence for root immutability. ZFS pools are created with encryption compression using zstd-3 atime disabled and automatic trim enabled. ARC size is configurable with a default of 8 GB. Snapshot management uses sanoid with configurable retention policies. Automatic scrub runs on a configurable schedule.

Impermanence makes the root filesystem ephemeral. Only directories and files listed in environment.persistence.persist are preserved across reboots. User data in persist and home persists. System state including machine-id resolv.conf and SSH keys is explicitly persisted. Disko provides declarative partitioning with disk layout defined in configuration not manual partitioning. Pre-rebuild and post-rebuild ZFS snapshots are created automatically via sanoid. The previous generation remains bootable through the boot menu entry.

## Container Architecture

Containers use MicroVM for hardware level isolation. Each guest runs as a separate microvm with dedicated vCPU memory and storage resources. The host configures a bridge interface called microvm for guest networking. Guests connect through this bridge. Socket forwarding enables X11 and Wayland forwarding for desktop application containers.

The orchestrator manages guest lifecycles including create start stop and destroy. It uses cgroup v2 for resource isolation at the pool level. The instance pool provides dynamic scaling. Key parameters include maxInstances basePort memPerInstance cpuPerInstance storagePerInstance appPackage appCommand and healthcheckCmd. The pool manager automatically spawns new instances up to the configured maximum and performs health checks on running instances. Caddy serves as a reverse proxy routing requests to the appropriate instance based on port mapping. The cgroup v2 hierarchy for containers is structured as sys fs cgroup hostname pool instance-001 and instance-002 each with cpu.max memory.max pids.max and io.max limits.

## Desktop Architecture

The desktop environment uses KDE Plasma 6 with a custom FlakeOS layout. KDE Plasma 6 is installed with essential components only including plasma-desktop kwin konsole dolphin kscreen plasma-nm plasma-pa bluedevil powerdevil kdecoration-viewer kactivitymanagerd and polkit-kde-agent-1. Discover and PIM applications are excluded.

The FlakeOS layout provides a top bar with global menu application launcher system tray clock and workspace switcher. A dock with favorites running applications and trash. Custom window decorations and button layout. A custom color scheme called BoraDark with a dark cosmic background and cyan accent. The color scheme uses background value 0A0C16 alternate background value 11131F foreground value C0C5D4 selection background value 7B2FBE selection foreground value FFFFFF active titlebar value 1A1C2B inactive titlebar value 0A0C16 accent value 00D4FF link value 00D4FF and visited link value 7B2FBE.

PipeWire provides audio with WirePlumber session manager and low latency configuration for real time audio. Desktop initialization scripts run at first login to configure the panel layout window rules and keyboard shortcuts through the KDE configuration system using kwriteconfig6.

## Build and Deploy

Build targets are defined in flake.nix outputs. nixosConfigurations.hostname provides standard NixOS configuration build. packages.system.iso-minimal provides minimal ISO image without desktop. packages.system.iso-graphical provides full ISO with desktop environment. The flake uses nixos-generators for ISO creation. The ISO configuration includes ZFS vfat and xfs filesystem support.

Four ISO variants are built through a matrix in CI: minimal desktop laptop server. Each variant is built by nix build targeting packages.system.iso-variant. The resulting ISO is renamed to flakeos-variant.iso for consistent naming. ISOs exceeding 1900 MB are split into 1900 MB parts to comply with GitHub 2 GB per file upload limit. Split ISOs are packaged in a zip archive together with a join.sh script that reassembles the parts via cat back into the original ISO. Small ISOs are uploaded directly as raw files. The release workflow creates a GitHub release with all ISOs and a changelog generated from .changelog entries.

For local ISO builds you use scripts/build/iso-build.sh which runs nix build for each variant and copies the resulting ISO to the dist directory. For split ISO reassembly you extract the zip and run bash join.sh flakeos-variant.iso.

The deployment workflow starts by setting hostname and username in src/hosts/target-host/meta.nix and optionally overriding the profile. Then run nixos-install flake hash target-host. Set a password for the user. Then reboot. Post deployment validation includes verifying ZFS pools and datasets are created correctly verifying firewall rules with nft list ruleset verifying SSH is accessible only via key from LAN verifying desktop layout has top bar dock and correct color scheme verifying microvm bridge interface exists and verifying cgroup v2 hierarchy is populated.

The rollback procedure involves selecting the previous generation from the boot menu or running nixos-rebuild switch rollback. Verify pre-rebuild ZFS snapshot exists via zfs list t snapshot.
