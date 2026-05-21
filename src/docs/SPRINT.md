# FLAKEOS NixOS Sprint Roadmap

## Sprint 10 — Release & CI Pipeline

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
