BORA NixOS - Architecture Document
Version 2.0.0

Table of Contents

1. Introduction
2. Repository Structure
3. Core Design Principles
4. Module System
5. Host and Profile System
6. Spring Framework (DI/IoC)
7. Security Architecture
8. Filesystem Architecture
9. Container Architecture
10. Desktop Architecture
11. Build and Deploy


1. Introduction

BORA is a modular, immutable NixOS configuration framework built on four pillars:

Zero Hardcoding: Every value is parameterized through Nix options. No usernames, hostnames, paths, IPs, or hardware identifiers are hardcoded. Host-specific values are declared in meta.nix files and injected via specialArgs.

Zero Comments: Nix files contain no comments. All technical documentation lives in AGENTS.md. User documentation lives in docs/. This enforces self-documenting code through meaningful identifier names and pure functional patterns.

Zero Inline Shell: Every shell script is stored as a standalone file in scripts/ and referenced via builtins.readFile. No script content appears inside Nix strings.

Pure Functions: Library functions in lib/ are pure with no side effects. Module evaluation is deterministic and idempotent.


2. Repository Structure

The repository follows a strict directory layout enforced by the module loader and build system.

Top Level:

flake.nix is the entry point. It declares inputs (nixpkgs, nixos-hardware, microvm, sops-nix, nixos-generators) and defines outputs for each discovered host plus ISO generation.

configuration.nix is the module loader. It auto-scans src/modules/ for category directories, imports each category's default.nix, and loads the selected profile from src/profiles/.

Source Tree:

src/hosts/ contains per-machine configurations. Each subdirectory is named after the host and contains meta.nix (system, hardware, profile, hostname, username), default.nix (host-specific config), and hardware.nix (generated hardware scan).

src/profiles/ defines use-case configurations: workstation (desktop + KDE + Bora layout), developer (workstation + dev tools), server (headless + container orchestrator), minimal (headless minimal).

src/modules/ is organized by category: core, filesystem, security, containers, desktop, hardware, network. Each category has a default.nix that imports submodules.

src/guests/ defines MicroVM guest templates. The sandbox.nix is a generic template. The example/ directory demonstrates a concrete instance definition with pool configuration.

lib/ contains pure Nix library functions: hardware detection database, Spring DI/IoC framework with circuit breaker, and the library aggregator.

config/ holds external configuration files referenced by modules: desktop panel layouts, NFTables rulesets, container bridge configuration.

scripts/ holds standalone shell scripts organized by subsystem: spring services, desktop initialization, pool management.

assets/ is reserved for static files: wallpapers, themes, fonts, icons.

secrets/ is reserved for encrypted secrets via SOPS and age.

tests/ contains pure Nix evaluation tests and a shell environment for linting with statix, deadnix, and nixpkgs-fmt.

docs/ contains documentation in plain text format.


3. Core Design Principles

Single Responsibility: Each .nix file has exactly one purpose. A file equals one module equals one function. No file mixes concerns.

Auto-Discovery: The configuration.nix module loader scans src/modules/ at evaluation time. No manual imports are needed when adding new modules. Each category's default.nix imports all submodules within that category.

Conditional Activation: Modules are enabled or disabled via mkIf cfg.enable. The enable option is declared in the module's options block. Profiles activate combinations of modules by setting these options to their preferred values.

Idempotency: nixos-rebuild switch is idempotent. Running it twice produces the same result. No state is modified outside the Nix store. User state lives exclusively in /persist and /home. The root filesystem is ephemeral through impermanence.

Atomicity: Every nixos-rebuild produces a new generation. The previous generation remains intact and selectable from the boot menu. Rollback uses nixos-rebuild switch --rollback. ZFS snapshots are taken automatically before and after rebuild via sanoid.

Parameterization: All configurable values use Nix options with mkOption. Default values use mkDefault so they can be overridden. Conditional values use mkIf. No literal values appear in configuration logic.


4. Module System

Modules are organized into categories under src/modules/. Each category represents a subsystem of the operating system.

core/: Boot configuration (systemd-boot, kernel parameters, initrd), Nix daemon settings (auto-optimise, garbage collection, substituters), locale and timezone, sysctl kernel parameters.

filesystem/: ZFS pool creation, ARC tuning, automatic trimming, scrub scheduling, sanoid snapshot retention, disko partitioning, impermanence configuration with persistent directories and files.

security/: NFTables firewall with default-drop policy, kernel hardening through sysctl, AppArmor enforcement with lockdown, SSH server hardening (key-only, rate-limited, minimal ciphers), Fail2ban for brute-force protection, audit logging.

containers/: MicroVM host configuration with bridge networking, orchestrator for managing guest lifecycles, instance pool for dynamic scaling of guest instances with cgroup v2 resource isolation.

desktop/: KDE Plasma 6 minimal installation, PipeWire audio server, Bora custom desktop layout (top bar, dock, global menu, cosmic dark theme).

hardware/: CPU-specific optimizations (Intel, AMD, ARM), GPU drivers and configuration (NVIDIA, AMD, Intel), platform tuning (desktop, laptop, server).

network/: Base network configuration, DNS resolver settings.

Each module defines an options block with an enable flag and all configurable parameters. The config block is wrapped in mkIf cfg.enable. Assertions validate parameter combinations at evaluation time.

New modules follow this pattern:

Create src/modules/category/name.nix with options and config.
Update src/modules/category/default.nix to import the new file.
Define options with mkOption and use mkIf for conditional config.
Use assertions to validate constraints.


5. Host and Profile System

Each host is defined in src/hosts/hostname/. The meta.nix file declares four attributes:

system: The NixOS system architecture (e.g. x86_64-linux).
hardware: The hardware class (desktop, laptop, server).
profile: The use-case profile name (workstation, developer, server, minimal).
hostname: The machine hostname.
username: The primary user name.

The flake.nix reads src/hosts/ to discover available hosts. It passes hostname and username from meta.nix as specialArgs to the NixOS configuration. This eliminates all hardcoded user and host references.

Profiles in src/profiles/ define combinations of enabled modules. A profile sets bora options to mkDefault values, establishing the baseline configuration for that use case. Profiles inherit from more basic profiles where applicable.

The configuration.nix loads the profile specified in meta.nix using a dynamic import based on the profile attribute.


6. Spring Framework (DI/IoC)

The Spring framework in lib/spring.nix provides dependency injection and circuit breaker patterns for systemd services.

Bean definitions use the bora.spring.beans attribute set. Each bean specifies:

class: A service type identifier for organizational purposes.
deps: A list of bean names this bean depends on.
resources: Resource limits for cgroup v2 isolation (cpu, memory, memoryMax, pids, ioRbps, ioWbps, numa).
healthcheck: A command that returns zero for healthy service.
dependsOn: Systemd unit dependencies.
after: Systemd unit ordering.
restartPolicy: Systemd restart policy.

The framework performs topological sort of bean dependencies at build time. Circular dependencies cause a build failure with a diagnostic message listing the cycle.

The circuit breaker implements a three-state machine:

CLOSED: Normal operation. Requests pass through. Failures increment a counter.
OPEN: Circuit is open. Requests are blocked. A timeout timer starts.
HALF-OPEN: Recovery test. Limited requests are allowed through.

Transitions:

CLOSED to OPEN when failures reach threshold (default 5).
OPEN to HALF-OPEN after timeout (default 30 seconds).
HALF-OPEN to CLOSED when successes reach threshold (default 2).
HALF-OPEN to OPEN on any failure in half-open state.

Cgroup v2 hierarchy is created under /sys/fs/cgroup/hostname/bean-name/ with cpu.max, memory.max, pids.max, and io.max limits. OOM policy is set to kill for all Spring services.

Health check flow executes the healthcheck command periodically. Success calls circuit_success which may transition to CLOSED. Failure calls circuit_trip which may transition to OPEN. When the circuit is OPEN, the service exits with code 1.


7. Security Architecture

Security is implemented in layers.

Kernel hardening uses sysctl parameters to restrict kernel pointer access, dmesg access, performance events, ptrace, BPF, kexec, and SysRq. ASLR is set to maximum. Unprivileged BPF is disabled. BPF JIT is disabled.

The firewall uses NFTables with a default-drop policy on the input chain. Only established/related connections, loopback traffic, rate-limited ICMP, and SSH from LAN addresses are accepted. The forward chain accepts established/related connections and traffic from the microvm bridge interface. The output chain has a default-accept policy.

SSH is hardened with no root login, no password authentication, key-only access, rate-limited authentication attempts, limited sessions, no TCP or agent forwarding, and modern cipher suites (ChaCha20-Poly1305, AES-256-GCM) with ETM MACs.

AppArmor is enforced with cache enabled. The apparmor-profiles package provides additional profiles. Lockdown is set to confidentiality.

Fail2ban monitors SSH and HTTP services. Audit logging captures security-relevant events.


8. Filesystem Architecture

The filesystem uses ZFS as the primary filesystem with impermanence for root immutability.

ZFS pools are created with encryption, compression (zstd-3), atime disabled, and automatic trim enabled. ARC size is configurable with a default of 8 GB. Snapshot management uses sanoid with configurable retention policies. Automatic scrub runs on a configurable schedule.

Impermanence makes the root filesystem ephemeral. Only directories and files listed in environment.persistence./persist are preserved across reboots. User data in /persist and /home persists. System state (machine-id, resolv.conf, SSH keys) is explicitly persisted.

Disko provides declarative partitioning. Disk layout is defined in configuration, not manual partitioning.

Pre-rebuild and post-rebuild ZFS snapshots are created automatically via sanoid. The previous generation remains bootable through the boot menu entry.


9. Container Architecture

Containers use MicroVM for hardware-level isolation. Each guest runs as a separate microvm with dedicated vCPU, memory, and storage resources.

The host configures a bridge interface (microvm) for guest networking. Guests connect through this bridge. Socket forwarding enables X11 and Wayland forwarding for desktop application containers.

The orchestrator manages guest lifecycles: create, start, stop, destroy. It uses cgroup v2 for resource isolation at the pool level.

The instance pool provides dynamic scaling. Key parameters include maxInstances, basePort, memPerInstance, cpuPerInstance, storagePerInstance, appPackage, appCommand, and healthcheckCmd. The pool manager automatically spawns new instances up to the configured maximum and performs health checks on running instances.

Caddy serves as a reverse proxy, routing requests to the appropriate instance based on port mapping.

Cgroup v2 hierarchy for containers:

/sys/fs/cgroup/
  hostname/
    pool/
      instance-001/  cpu.max, memory.max, pids.max, io.max
      instance-002/  same


10. Desktop Architecture

The desktop environment uses KDE Plasma 6 with a custom Bora layout.

KDE Plasma 6 is installed with essential components only: plasma-desktop, kwin, konsole, dolphin, kscreen, plasma-nm, plasma-pa, bluedevil, powerdevil, kdecoration-viewer, kactivitymanagerd, polkit-kde-agent-1. Discover and PIM applications are excluded.

The Bora layout provides:

A top bar with global menu, application launcher, system tray, clock, and workspace switcher.
A dock with favorites, running applications, and trash.
Custom window decorations and button layout.
A custom color scheme (BoraDark) with a dark cosmic background and cyan accent.

The color scheme uses these values:

Background: #0A0C16
Alternate Background: #11131F
Foreground: #C0C5D4
Selection Background: #7B2FBE
Selection Foreground: #FFFFFF
Active Titlebar: #1A1C2B
Inactive Titlebar: #0A0C16
Accent: #00D4FF
Link: #00D4FF
Visited Link: #7B2FBE

PipeWire provides audio with WirePlumber session manager and low-latency configuration for real-time audio.

Desktop initialization scripts run at first login to configure the panel layout, window rules, and keyboard shortcuts through the KDE configuration system (kwriteconfig6).


11. Build and Deploy

Build targets are defined in flake.nix outputs:

nixosConfigurations.hostname: Standard NixOS configuration build.
packages.system.iso-minimal: Minimal ISO image without desktop.
packages.system.iso-graphical: Full ISO with desktop environment.

The flake uses nixos-generators for ISO creation. The ISO configuration includes ZFS, vfat, and xfs filesystem support.

Deployment workflow:

Set hostname and username in src/hosts/target-host/meta.nix.
Optionally override profile.
Run nixos-install --flake .#target-host.
Set a password for the user.
Reboot.

Post-deployment validation:

Verify ZFS pools and datasets are created correctly.
Verify firewall rules with nft list ruleset.
Verify SSH is accessible only via key from LAN.
Verify desktop layout has top bar, dock, and correct color scheme.
Verify microvm bridge interface exists.
Verify cgroup v2 hierarchy is populated.

Rollback procedure:

Select previous generation from boot menu.
Or run nixos-rebuild switch --rollback.
Verify pre-rebuild ZFS snapshot exists via zfs list -t snapshot.
