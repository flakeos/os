# FlakeOS Sprint Definitions

## Completed Sprints

### Sprint 1 — Foundation

The goal of Sprint 1 was to create the base system structure. This includes `flake.nix` as the pure entry point with declarative inputs, `configuration.nix` as the auto-scan module loader, `lib/default.nix` exporting all libraries, `lib/hardware.nix` as the CPU, GPU, and Platform database, `src/module/core` for Boot, Nix, Locale, and Sysctl, `src/hosts/hostname` with meta, default, and hardware, and AGENTS.md.

### Sprint 2 — Filesystem and Immutability

The goal of Sprint 2 was to implement ZFS, Impermanence, and Disko. This includes the ZFS module for pool, ARC, and snapshot configuration, the impermanence module for persistent storage on an ephemeral root, sanoid for automatic snapshot retention, and disko for declarative partitioning.

### Sprint 3 — Security

The goal of Sprint 3 was to implement extreme hardening, firewall, and SSH. This includes the firewall module with NFTables default drop, the external NFTables configuration, the hardening module for kernel and AppArmor, the SSH module with key-only and LAN-only access, and audit logging with Fail2ban.

### Sprint 4 — Hardware Detection

The goal of Sprint 4 was to auto-configure CPU, GPU, and Platform. This includes the CPU module for Intel, AMD, and ARM, the GPU module for NVIDIA, AMD, and Intel, the platform module for Desktop, Laptop, and Server, and `lib/hardware.nix` as the vendor optimization database.

### Sprint 5 — Desktop and FlakeOS Layout

The goal of Sprint 5 was to create a minimal KDE Plasma 6 desktop. This includes the KDE minimal module for essential Plasma 6, the PipeWire module for audio, and impermanence persistence for KDE state. The original FlakeOS macOS-like layout was later replaced with GNOME Yaru and Hyprland Yaru Ubuntu-like desktops.

### Sprint 6 — Container Engine

The goal of Sprint 6 was to create the container engine with hardware-level isolation. This includes the microvm-host module for host and bridge, the orchestrator module for pool management, the sandbox guest as a generic template, the containers configuration for bridge and networking, and SocketVM for desktop apps with X11 and Wayland forwarding.

### Sprint 7 — Spring Framework

The goal of Sprint 7 was to implement Dependency Injection and Circuit Breaker. This includes `lib/spring.nix` for bean definitions, topological sort, `mkSystemdService` with resource limits, circuit breaker with failure, success, and state management, circular dependency detection, and the spring scripts for circuit-breaker, health, and bean-wrapper. The orchestrator was also updated to use Spring beans.

### Sprint 8 — Instance Pool Orchestrator

The goal of Sprint 8 was to create the pool of isolated instances for any application. This includes the instance-pool module with pool options, the guest definition per application, the pool configuration, the pool scripts for pool-manager with spawn, list, and stats commands, cgroup v2 for per-instance resource isolation, and Caddy reverse proxy for routing to instances.

### Sprint 9 — Testing and Documentation

The goal of Sprint 9 was to implement pure Nix tests and complete documentation. This includes `src/tests/default.nix` for pure library tests, `docs/` as user manual in text format, AGENTS.md with always-updated agentic rules, and ISO generation for immediate deploy.

The sprint flow proceeds from Sprint 1 through Sprint 9 sequentially. Each sprint produces a working NixOS generation without unsatisfied dependencies. All sprints from 1 to 9 are completed.

---

## Future Sprint Roadmap

### Sprint 10 — Release and CI Pipeline

The goal of Sprint 10 is to create a production-grade release pipeline with automated ISO publishing.

- Package split ISOs in zip with join.sh reassembly script
- Automate release notes generation from .changelog
- Add GPG signing for release assets (conditional on secret)
- Add SHA256 checksum file per release
- Add smoke tests for ISO boot in CI
- Add `nix flake check` to validation gate
- Multi-architecture ISO builds (aarch64)

### Sprint 11 — Extended Hardware Support

The goal of Sprint 11 is to auto-detect and optimize for all common hardware.

- Add CPU microcode updates for Intel and AMD
- Add GPU modesetting and VA-API for Intel, AMD, and NVIDIA
- Add platform-specific power management (laptop battery, desktop performance)
- Add NVMe SSD optimizations (IO scheduler, power saving)
- Add Thunderbolt and USB4 support (bolt daemon)
- Add fingerprint reader and other biometrics (fprintd)

### Sprint 12 — Enhanced Desktop

The goal of Sprint 12 is to deliver a polished desktop experience out of the box.

- Add GNOME desktop variant with Yaru Ubuntu theme
- Add Hyprland desktop variant with Waybar and Yaru Ubuntu theme
- Add KDE Plasma 6 minimal desktop variant
- Add default application set (Firefox, Thunderbird, LibreOffice, GIMP)
- Add FlakeOS wallpaper and cursor theme
- Add print support (CUPS)
- Add Bluetooth audio codec configuration
- Add fractional scaling defaults

### Sprint 13 — Security Hardening

The goal of Sprint 13 is to exceed CIS and DISA STIG benchmarks for NixOS.

- Add USBGuard for USB device authorization
- Add TPM2-based disk encryption
- Add SELinux or enhanced AppArmor profiles per service
- Add kernel module blacklisting
- Add secure boot support
- Add systemd-journald remote logging
- Add AIDE or Tripwire file integrity monitoring
- Add vulnerability scanning with vulnix

### Sprint 14 — Monitoring and Observability

The goal of Sprint 14 is to provide comprehensive system health dashboard and alerting.

- Add Prometheus node exporter and metrics collection
- Add Grafana dashboard for system overview
- Add Loki for centralized logging
- Add Alertmanager rules for disk, memory, CPU thresholds
- Add systemd health check service
- Add ZFS pool monitoring with alerts

### Sprint 15 — Container Ecosystem

The goal of Sprint 15 is to provide extensive MicroVM guest templates and orchestration.

- Add database guest templates (PostgreSQL, MySQL, Redis)
- Add web application guest templates (Nginx, Caddy, Apache)
- Add media server templates (Jellyfin, Navidrome)
- Add development environment templates
- Add guest migration between hosts
- Add load balancing across instance pools
- Add persistent storage volumes for guests

### Sprint 16 — Developer Experience

The goal of Sprint 16 is to make FlakeOS the fastest way to bootstrap a NixOS project.

- Add `flakeos init` scaffolding command
- Add `flakeos add-module` generator
- Add `flakeos add-host` templating
- Add documentation generator from module options
- Add integration tests for every module
- Add flake check hooks
- Add GitHub template repository with CI/CD examples
