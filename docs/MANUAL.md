# BORA NixOS User Manual

## 1. Getting started

To deploy BORA on a new machine first create a host directory under src/hosts with a meta.nix file containing the system architecture hardware profile hostname and username. Then run nixos-install flake hash target-host. After installation reboot and verify the system.

## 2. Host configuration

Each host is defined in src/hosts/hostname. The meta.nix file must export an attribute set with four keys. system is the architecture like x86_64-linux. hardware is the hardware class like desktop laptop or server. profile is the use case profile like workstation developer server or minimal. hostname is the machine hostname. username is the primary user name.

## 3. Profile selection

Profiles define which modules are enabled. The workstation profile enables desktop KDE and Bora layout. The developer profile adds development tools. The server profile is headless with container orchestrator. The minimal profile is a headless base system.

## 4. Filesystem and storage

The default filesystem layout uses ZFS with encryption and compression. The root filesystem is ephemeral through impermanence with persistent data stored under persist. The disko module provides declarative partitioning.

## 5. Container engine

MicroVM guests provide hardware level isolation. The orchestrator manages guest lifecycles. The instance pool provides dynamic scaling with cgroup v2 resource limits. Caddy serves as reverse proxy for routed instances.

## 6. Desktop environment

KDE Plasma 6 minimal with custom Bora layout including top bar dock global menu and dark color scheme. PipeWire provides audio with low latency configuration.

## 7. Security

Firewall default drop with NFTables. Kernel hardening through sysctl. SSH key only from LAN. AppArmor enforced. Fail2ban active. Audit logging enabled.

## 8. Spring framework

Dependency injection for systemd services with circuit breaker. Bean definitions per service. Health based auto recovery. Cgroup v2 resource isolation.

## 9. Maintenance

### 9.1 System updates

Run nix flake update to update all inputs then nixos-rebuild switch to apply.

### 9.2 ZFS maintenance

Monitor pool status with zpool status. Check scrub progress with zpool scrub. List snapshots with zfs list t snapshot.

### 9.3 Troubleshooting

Check service status with systemctl status bora bean name. View logs with journalctl u bora bean name. Verify firewall with nft list ruleset. Check cgroup usage with systemd cgtop.
