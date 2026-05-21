# FLAKEOS NixOS Sprint Definitions

## Completed Sprints

### Sprint 1 — Foundation

Goal: create the base system structure. Includes flake.nix as pure entry point with declarative inputs, configuration.nix as auto scan module loader, lib/default.nix exporting all libraries, lib/hardware.nix as CPU GPU and Platform database, src/module/core for Boot Nix Locale and Sysctl, src/hosts/hostname with meta default and hardware, and AGENTS.md.

### Sprint 2 — Filesystem and Immutability

Goal: implement ZFS Impermanence and Disko. Includes the zfs module for pool ARC and snapshot, the impermanence module for persist config desktop for external config files, sanoid for automatic snapshot retention, and disko for declarative partitioning.

### Sprint 3 — Security

Goal: implement extreme hardening, firewall, and SSH. Includes the firewall module with nftables default drop, the external nftables configuration, the hardening module for kernel and AppArmor, the ssh module with keys only LAN only, and audit logging with fail2ban.

### Sprint 4 — Hardware Detection

Goal: auto configure CPU GPU and Platform. Includes the cpu module for Intel AMD and ARM, the gpu module for NVIDIA AMD and Intel, the platform module for Desktop Laptop and Server, and lib/hardware.nix as vendor optimization database.

### Sprint 5 — Desktop and FlakeOS Layout

Goal: create minimal KDE Plasma 6 with original FlakeOS layout. Includes the kde-minimal module for essential Plasma 6, the layout module for the FlakeOS theme, the pipewire module for audio, the layout scripts for init and finalize shell, and the desktop config files for plasma-appletsrc kdeglobals and kwinrc.

### Sprint 6 — Container Engine

Goal: create the container engine with hardware level isolation. Includes the microvm-host module for host and bridge, the orchestrator module for pool manager, the sandbox guest as generic template, the containers configuration for bridge and networking, and SocketVM for desktop apps with X11 and Wayland forwarding.

### Sprint 7 — Spring Framework

Goal: implement Dependency Injection and Circuit Breaker. Includes lib/spring.nix for bean definitions, topological sort, mkSystemdService with resource limits, circuit breaker with failure success and state circular dependency detection, and the spring scripts for circuit-breaker, health, and bean-wrapper. Also includes the orchestrator update to use Spring beans.

### Sprint 8 — Instance Pool Orchestrator

Goal: create the pool of isolated instances for any application. Includes the instance-pool module with pool options, the guest definition per application, the pool configuration, the pool scripts for pool-manager spawn list and stats, cgroup v2 for per instance resource isolation, and Caddy reverse proxy for routing to instances.

### Sprint 9 — Testing and Documentation

Goal: implement pure Nix tests and complete documentation. Includes src/tests/default.nix for pure library tests, docs as user manual in text format, AGENTS.md with always updated agentic rules, and ISO generation for immediate deploy.

The sprint flow proceeds from Sprint 1 through Sprint 9 sequentially. Each sprint produces a working NixOS generation without unsatisfied dependencies. All sprints from 1 to 9 are completed.

---

## Future Sprint Roadmap

### Sprint 10 — Release & CI Pipeline

Goal: production-grade release pipeline with automated ISO publishing.

- [x] Package split ISOs in zip with join.sh reassembly script
- [ ] Automate release notes generation from .changelog
- [ ] Add GPG signing for release assets
- [ ] Add SHA256 checksum file per release
- [ ] Add smoke tests for ISO boot in CI
- [ ] Add `nix flake check` to validation gate
- [ ] Multi-architecture ISO builds (aarch64)

## Sprint 11 — Extended Hardware Support

Goal: auto-detect and optimize for all common hardware.

- [ ] Add CPU microcode updates for Intel/AMD
- [ ] Add GPU modesetting and VA-API for Intel/AMD/NVIDIA
- [ ] Add platform-specific power management (laptop battery, desktop performance)
- [ ] Add NVMe SSD optimizations
- [ ] Add Thunderbolt and USB4 support
- [ ] Add fingerprint reader and other biometrics

## Sprint 12 — Enhanced Desktop

Goal: polished KDE Plasma 6 experience out of the box.

- [ ] Add default application set (Firefox, Thunderbird, LibreOffice, GIMP)
- [ ] Add FlakeOS wallpaper and cursor theme
- [ ] Add preconfigured KDE activities per profile
- [ ] Add print support (CUPS)
- [ ] Add Bluetooth audio codec configuration
- [ ] Add desktop notifications and Do Not Disturb workflow
- [ ] Add fractional scaling defaults

## Sprint 13 — Security Hardening

Goal: exceed CIS and DISA STIG benchmarks for NixOS.

- [ ] Add USBGuard for USB device authorization
- [ ] Add TPM2-based disk encryption
- [ ] Add SELinux or enhanced AppArmor profiles per service
- [ ] Add kernel module blacklisting
- [ ] Add secure boot support
- [ ] Add systemd-journald remote logging
- [ ] Add AIDE or Tripwire file integrity monitoring
- [ ] Add vulnerability scanning with vulnix

## Sprint 14 — Monitoring & Observability

Goal: comprehensive system health dashboard and alerting.

- [ ] Add Prometheus node exporter and metrics collection
- [ ] Add Grafana dashboard for system overview
- [ ] Add Loki for centralized logging
- [ ] Add Alertmanager rules for disk, memory, CPU thresholds
- [ ] Add systemd health check service
- [ ] Add ZFS pool monitoring with alerts

## Sprint 15 — Container Ecosystem

Goal: extensive MicroVM guest templates and orchestration.

- [ ] Add database guest templates (PostgreSQL, MySQL, Redis)
- [ ] Add web application guest templates (Nginx, Caddy, Apache)
- [ ] Add media server templates (Jellyfin, Navidrome)
- [ ] Add development environment templates
- [ ] Add guest migration between hosts
- [ ] Add load balancing across instance pools
- [ ] Add persistent storage volumes for guests

## Sprint 16 — Developer Experience

Goal: make FLAKEOS the fastest way to bootstrap a NixOS project.

- [ ] Add `flakeos init` scaffolding command
- [ ] Add `flakeos add-module` generator
- [ ] Add `flakeos add-host` templating
- [ ] Add documentation generator from module options
- [ ] Add integration tests for every module
- [ ] Add flake check hooks
- [ ] Add GitHub template repository with CI/CD examples
