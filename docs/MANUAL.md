# FLAKEOS NixOS User Manual

## Getting Started

To deploy FLAKEOS on a new machine first create a host directory under src/hosts with a meta.nix file containing the system architecture hardware profile hostname and username. Then run nixos-install flake hash target-host. After installation reboot and verify the system.

## Host Configuration

Each host is defined in src/hosts/hostname. The meta.nix file must export an attribute set with four keys. system is the architecture like x86_64-linux. hardware is the hardware class like desktop laptop or server. profile is the use case profile like workstation developer server or minimal. hostname is the machine hostname. username is the primary user name.

## Profile Selection

Profiles define which modules are enabled. The workstation profile enables desktop KDE and FlakeOS layout. The developer profile adds development tools. The server profile is headless with container orchestrator. The minimal profile is a headless base system.

## Filesystem and Storage

The default filesystem layout uses ZFS with encryption and compression. The root filesystem is ephemeral through impermanence with persistent data stored under persist. The disko module provides declarative partitioning.

## Container Engine

MicroVM guests provide hardware level isolation. The orchestrator manages guest lifecycles. The instance pool provides dynamic scaling with cgroup v2 resource limits. Caddy serves as reverse proxy for routed instances.

## Desktop Environment

KDE Plasma 6 minimal with custom FlakeOS layout including top bar dock global menu and dark color scheme. PipeWire provides audio with low latency configuration.

## Security

Firewall default drop with NFTables. Kernel hardening through sysctl. SSH key only from LAN. AppArmor enforced. Fail2ban active. Audit logging enabled.

## Spring Framework

Dependency injection for systemd services with circuit breaker. Bean definitions per service. Health based auto recovery. Cgroup v2 resource isolation.

## Maintenance

For system updates run nix flake update to update all inputs then nixos-rebuild switch to apply. For ZFS maintenance monitor pool status with zpool status check scrub progress with zpool scrub and list snapshots with zfs list t snapshot. For troubleshooting check service status with systemctl status flakeos bean name view logs with journalctl u flakeos bean name verify firewall with nft list ruleset and check cgroup usage with systemd cgtop.
