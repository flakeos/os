BORA NixOS User Manual

This manual covers the BORA NixOS framework. BORA provides a modular immutable NixOS configuration framework with advanced features including dependency injection for systemd services MicroVM container isolation and declarative desktop configuration.

Getting started

To deploy BORA on a new machine first create a host directory under src/hosts with a meta.nix file containing the system architecture hardware profile hostname and username. Then run nixos-install flake hash target-host. After installation reboot and verify the system.

Host configuration

Each host is defined in src/hosts/hostname. The meta.nix file must export an attribute set with four keys. system is the architecture like x86_64-linux. hardware is the hardware class like desktop laptop or server. profile is the use case profile like workstation developer server or minimal. hostname is the machine hostname. username is the primary user name.

Profile selection

Profiles define which modules are enabled. The workstation profile enables desktop KDE and Bora layout. The developer profile adds development tools. The server profile is headless with container orchestrator. The minimal profile is a headless base system.

Filesystem and storage

The default filesystem layout uses ZFS with encryption and compression. The root filesystem is ephemeral through impermanence with persistent data stored under persist. The disko module provides declarative partitioning.

Container engine

MicroVM guests provide hardware level isolation. The orchestrator manages guest lifecycles. The instance pool provides dynamic scaling with cgroup v2 resource limits. Caddy serves as reverse proxy for routed instances.

Desktop environment

KDE Plasma 6 minimal with custom Bora layout including top bar dock global menu and dark color scheme. PipeWire provides audio with low latency configuration.

Security

The firewall uses NFTables with default drop policy. SSH is key only with LAN restriction and modern ciphers. Kernel hardening restricts ptrace BPF kexec and performance events. AppArmor is enforced with lockdown.

Build and deploy

Use nix build to build configurations and nixos-rebuild switch to apply them. ISO images are available in minimal and graphical variants. Rollback uses nixos-rebuild switch rollback or boot menu selection.
