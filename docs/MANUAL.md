# FlakeOS User Manual

## Getting Started

To deploy FlakeOS on a new machine, create a host directory under `src/hosts` with a `meta.nix` file containing the system architecture, hardware profile, hostname, and username. Then run `nixos-install --flake github:flakeos/os#target-host`. After installation, reboot and verify the system.

### ISO Variants

If you are deploying from an ISO, six variants are available. The **minimal** variant is headless with no desktop, suitable for servers and containers. The **desktop** variant includes KDE Plasma 6 with FlakeOS layout for workstations with GPU. The **GNOME** variant includes GNOME with Yaru Ubuntu theme for workstations with GPU. The **Hyprland** variant includes Hyprland with GNOME-like Waybar desktop for workstations with GPU. The **laptop** variant includes the desktop variant plus power management and touchpad configuration. The **server** variant includes the minimal variant plus container orchestrator and instance pool.

## Host Configuration

Each host is defined in `src/hosts/hostname`. The `meta.nix` file must export an attribute set with four keys: `system` is the architecture such as `x86_64-linux`, `hardware` is the hardware class such as desktop, laptop, or server, `profile` is the use case profile such as workstation, developer, server, or minimal, `hostname` is the machine hostname, and `username` is the primary user name.

### Example

The following example shows a `meta.nix` file for a development machine:

```
{
  system = "x86_64-linux";
  hardware = "desktop";
  profile = "developer";
  hostname = "devbox";
  username = "alice";
}
```

After creating `meta.nix`, run `sudo nixos-install --flake github:flakeos/os#devbox` to install. The hash is the Git revision, or for a local checkout you can use the path directly.

## Profile Selection

Profiles define which modules are enabled. The **workstation** profile enables desktop, KDE, and FlakeOS layout. The **GNOME** profile enables GNOME with Yaru Ubuntu theme. The **Hyprland** profile enables Hyprland compositor with Waybar system tray and GNOME-like appearance. The **developer** profile adds development tools such as Git, VS Code, Docker, and language runtimes on top of workstation. The **server** profile is headless with container orchestrator for running MicroVM guests. The **minimal** profile is a headless base system with networking, SSH, and security hardening only.

To change the profile of an existing host, edit the `profile` key in `meta.nix` and run `nixos-rebuild switch`. The system will reconfigure itself with the new module set.

## Filesystem and Storage

The default filesystem layout uses ZFS with encryption and compression. The root filesystem is ephemeral through impermanence, with persistent data stored under `/persist`. The disko module provides declarative partitioning.

### ZFS Maintenance

Key ZFS maintenance commands include `zpool status` to check pool health, `zpool list` to see pool capacity, `zfs list` to inspect datasets, and `zpool scrub` to start a scrub. Snapshots are managed automatically by sanoid with configurable retention in the ZFS module options.

## ISO Build and Installation

To build an ISO locally, run `src/scripts/build/iso-build.sh` from the repository root. This produces ISO files in the `dist` directory. The script requires Nix with flakes enabled and sufficient disk space for the build.

### Release ISOs

Release ISOs are published on the GitHub releases page. ISOs larger than 1900 MB appear as zip files containing split parts and a `join.sh` reassembly script. To use a split ISO, download the zip, extract it, and run `bash join.sh flakeos-variant.iso`. This produces the original ISO file ready for writing to USB with `dd` or balenaEtcher.

### USB Installation

For USB installation, write the ISO to a USB drive with `sudo dd if=flakeos-variant.iso of=/dev/sdX bs=4M status=progress conv=fsync`. Replace `sdX` with your USB device path. Then boot from the USB and run the NixOS installer.

## Container Engine

MicroVM guests provide hardware-level isolation. The orchestrator manages guest lifecycles. The instance pool provides dynamic scaling with cgroup v2 resource limits. Caddy serves as a reverse proxy for routed instances.

### Creating a Guest

To create a new guest, define a guest configuration in `src/guests/your-guest/default.nix` following the sandbox template. Enable the microvm-host module and configure the orchestrator to include your guest. The guest will start automatically on boot and be managed by the orchestrator.

### Pool Management

Pool instances are managed via `scripts/pool/pool-manager.sh`, which supports `spawn`, `list`, and `stats` commands. Each instance gets isolated CPU, memory, and I/O resources through cgroup v2.

## Desktop Environment

FlakeOS supports three desktop environments. KDE Plasma 6 is installed minimally with custom FlakeOS layout including top bar, dock, global menu, and dark color scheme. GNOME uses the Yaru theme providing a Ubuntu-like desktop experience. Hyprland uses Waybar top bar, rofi launcher, and sway notifications styled after GNOME for a clean, modern workspace. PipeWire provides audio with low latency configuration.

### Desktop Layout

The desktop layout is applied automatically on first login through initialization scripts. Key customizations include a top panel with global menu, app launcher, system tray, and workspace switcher, and a bottom dock with application favorites and running tasks. Window decorations use the BoraDark color scheme with cyan accent.

If the desktop layout does not apply correctly, you can reinitialize it by running the layout init script from `src/scripts/desktop/init-layout.sh`.

## Security

Security is implemented in layers. The firewall defaults to drop with NFTables. Kernel hardening is applied through sysctl parameters. SSH is configured for key-only authentication from LAN. AppArmor is enforced. Fail2ban is active. Audit logging is enabled.

### Checking Security Status

To check firewall status, run `sudo nft list ruleset`. To check AppArmor status, run `sudo aa-status`. To view Fail2ban status, run `sudo fail2ban-client status`. SSH is configured to listen only on LAN addresses with key authentication only and root login disabled.

## Spring Framework

The Spring framework provides dependency injection for systemd services with circuit breaker pattern. Bean definitions are configured per service. Health-based auto recovery is automatic. Cgroup v2 provides resource isolation.

### Service Management

Each Spring service runs as a systemd unit under the flakeos target. Service health is checked periodically, and the circuit breaker tracks failures. If a service exceeds the failure threshold, the circuit opens and the service is stopped. After a timeout, the circuit transitions to half-open and allows a test request. On success, the circuit closes and normal operation resumes.

To inspect Spring services, run `systemctl list-units --all 'flakeos-*'`. To check the circuit breaker state, inspect the service journal with `journalctl --unit flakeos-bean-name`.

## Maintenance

### System Updates

For system updates, run `nix flake update` to update all inputs, then `nixos-rebuild switch` to apply.

### ZFS Maintenance

Monitor pool status with `zpool status`. Check scrub progress with `zpool scrub`. List snapshots with `zfs list -t snapshot`.

### Troubleshooting

For troubleshooting, check service status with `systemctl status flakeos-bean-name`, view logs with `journalctl --unit flakeos-bean-name`, verify firewall with `nft list ruleset`, and check cgroup usage with `systemd-cgtop`.

### Rollback

To roll back to a previous generation, boot into the desired generation from the systemd-boot menu or run `nixos-rebuild switch --rollback`. ZFS snapshots taken before and after each rebuild provide additional data recovery options. List available snapshots with `zfs list -t snapshot`.
