# FLAKEOS NixOS User Manual

## Getting Started

To deploy FLAKEOS on a new machine first create a host directory under src/hosts with a meta.nix file containing the system architecture hardware profile hostname and username. Then run nixos-install flake hash target-host. After installation reboot and verify the system.

If you are deploying from an ISO the ISO is available in five variants. minimal is headless with no desktop for servers and containers. desktop includes KDE Plasma 6 with FlakeOS layout for workstations with GPU. hyprland includes Hyprland with GNOME-like Waybar desktop for workstations with GPU. laptop includes the desktop variant plus power management and touchpad configuration. server includes the minimal variant plus container orchestrator and instance pool.

## Host Configuration

Each host is defined in src/hosts/hostname. The meta.nix file must export an attribute set with four keys. system is the architecture like x86_64-linux. hardware is the hardware class like desktop laptop or server. profile is the use case profile like workstation developer server or minimal. hostname is the machine hostname. username is the primary user name.

Example meta.nix for a development machine:

```
{
  system = "x86_64-linux";
  hardware = "desktop";
  profile = "developer";
  hostname = "devbox";
  username = "alice";
}
```

After creating meta.nix run sudo nixos-install --flake path hash devbox to install. The hash is the Git revision or for a local checkout you can use the path directly.

## Profile Selection

Profiles define which modules are enabled. The workstation profile enables desktop KDE and FlakeOS layout. The hyprland profile enables Hyprland compositor with Waybar system tray and GNOME-like appearance. The developer profile adds development tools like git vscode docker and language runtimes on top of workstation. The server profile is headless with container orchestrator for running MicroVM guests. The minimal profile is a headless base system with networking SSH and security hardening only.

To change the profile of an existing host edit the profile key in meta.nix and run nixos-rebuild switch. The system will reconfigure itself with the new module set.

## Filesystem and Storage

The default filesystem layout uses ZFS with encryption and compression. The root filesystem is ephemeral through impermanence with persistent data stored under persist. The disko module provides declarative partitioning.

Key ZFS maintenance commands include zpool status to check pool health zpool list to see pool capacity zfs list to inspect datasets and zpool scrub to start a scrub. Snapshots are managed automatically by sanoid with configurable retention in the zfs module options.

## ISO Build and Installation

To build an ISO locally run scripts/build/iso-build.sh from the repository root. This produces four ISO files in the dist directory. The script requires Nix with flakes enabled and sufficient disk space for the build.

Release ISOs are published on the GitHub releases page. ISOs larger than 1900 MB appear as zip files containing split parts and a join.sh reassembly script. To use a split ISO download the zip extract it and run bash join.sh flakeos-variant.iso. This produces the original ISO file ready for writing to USB with dd or balenaEtcher.

For USB installation write the ISO to a USB drive with sudo dd if=flakeos-variant.iso of=/dev/sdX bs=4M status=progress conv=fsync. Replace sdX with your USB device path. Then boot from the USB and run the NixOS installer.

## Container Engine

MicroVM guests provide hardware level isolation. The orchestrator manages guest lifecycles. The instance pool provides dynamic scaling with cgroup v2 resource limits. Caddy serves as reverse proxy for routed instances.

To create a new guest define a guest configuration in src/guests/your-guest/default.nix following the sandbox template. Enable the microvm-host module and configure the orchestrator to include your guest. The guest will start automatically on boot and be managed by the orchestrator.

Pool instances are managed via scripts/pool/pool-manager.sh which supports spawn list and stats commands. Each instance gets isolated CPU memory and I/O resources through cgroup v2.

## Desktop Environment

KDE Plasma 6 minimal with custom FlakeOS layout including top bar dock global menu and dark color scheme. Hyprland with Waybar top bar rofi launcher and sway notifications styled after GNOME for a clean modern workspace. PipeWire provides audio with low latency configuration.

The desktop layout is applied automatically on first login through initialization scripts. Key customizations include a top panel with global menu app launcher system tray and workspace switcher. A bottom dock with application favorites and running tasks. Window decorations use BoraDark color scheme with cyan accent.

If the desktop layout does not apply correctly you can reinitialize it by running the layout init script from src/scripts/desktop/init-layout.sh.

## Security

Firewall default drop with NFTables. Kernel hardening through sysctl. SSH key only from LAN. AppArmor enforced. Fail2ban active. Audit logging enabled.

To check firewall status run sudo nft list ruleset. To check AppArmor status run sudo aa-status. To view Fail2ban status run sudo fail2ban-client status. SSH is configured to listen only on LAN addresses with key authentication only and root login disabled.

## Spring Framework

Dependency injection for systemd services with circuit breaker. Bean definitions per service. Health based auto recovery. Cgroup v2 resource isolation.

Each Spring service runs as a systemd unit under the flakeos target. Service health is checked periodically and the circuit breaker tracks failures. If a service exceeds the failure threshold the circuit opens and the service is stopped. After a timeout the circuit transitions to half-open and allows a test request. On success the circuit closes and normal operation resumes.

To inspect Spring services run systemctl list-units --all flakeos-asterisk. To check the circuit breaker state inspect the service journal with journalctl --unit flakeos-bean-name.

## Maintenance

For system updates run nix flake update to update all inputs then nixos-rebuild switch to apply. For ZFS maintenance monitor pool status with zpool status check scrub progress with zpool scrub and list snapshots with zfs list t snapshot. For troubleshooting check service status with systemctl status flakeos-bean-name view logs with journalctl --unit flakeos-bean-name verify firewall with nft list ruleset and check cgroup usage with systemd-cgtop.

To roll back to a previous generation boot into the desired generation from the systemd-boot menu or run nixos-rebuild switch rollback. ZFS snapshots taken before and after each rebuild provide additional data recovery options. List available snapshots with zfs list -t snapshot.
