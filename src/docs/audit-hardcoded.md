# Hardcoded Values Audit

Audit of all hardcoded values found across the FlakeOS codebase, their resolution status, and residual risks.

## Legend

- **FIXED** — Value converted to `mkOption` with `mkDefault` or to `${VAR:?required}`
- **RESIDUAL** — Still hardcoded; requires intervention
- **DESIGN** — Hardcoded by design (data library, intrinsic constraint)
- **INTRINSIC** — Cannot be parameterized (kernel paths, protocol names)

---

## 1. Shell Scripts — `${VAR:-default}` Fallbacks

| File | Line | Original | Status |
|------|------|----------|--------|
| `src/scripts/containers/setup-cgroup.sh` | 5–9 | `MEM="${2:-256M}"`, `CPU="${3:-0.5}"`, `PIDS="${4:-512}"`, `STORAGE="${5:-2G}"`, `IO_DEVICE="${6:-8:0}"` | **FIXED** → `${VAR:?required}` |
| `src/scripts/containers/orchestrator.sh` | 7 | `INTERVAL="${4:-30}"` | **FIXED** → `${4:?INTERVAL required}` |
| `src/scripts/containers/create-pool-zfs.sh` | 6 | `QUOTA="${3:-2G}"` | **FIXED** → `${3:?QUOTA required}` |
| `src/scripts/pool/spawn.sh` | 7 | `PORT="${1:-$((BASE_PORT + RUNNING + 1))}"` | **FIXED** → `${1:?PORT required}` |

---

## 2. Shell Scripts — Hardcoded Paths

| File | Line | Path | Risk | Status |
|------|------|------|------|--------|
| `src/scripts/containers/orchestrator.sh` | 10 | `/sys/fs/cgroup/cgroup.subtree_control` | Breaks if cgroup v2 root moves | **RESIDUAL** — kernel intrinsic |
| `src/scripts/spring/spring-resources.sh` | 7 | `/sys/fs/cgroup/${APP}/*` | Breaks if cgroup base changes | **RESIDUAL** — kernel intrinsic |
| `src/scripts/spring/spring-status.sh` | 14 | `/run/flakeos-cb/*-state` | Breaks if CB_DIR changed | **RESIDUAL** — not parameterized from Nix |
| `src/scripts/pool/pool-manager.sh` | 13 | `/sys/fs/cgroup/flakeos/pool` | Breaks if CG_DIR changes | **RESIDUAL** — env var exists but script has fallback mkdir |
| `src/scripts/pool/stats.sh` | 16 | `/sys/fs/cgroup/flakeos/pool/"${INST_ID}"` | Breaks if CG_DIR changes | **RESIDUAL** — not parameterized |
| `src/scripts/system/list-generations.sh` | 4 | `/nix/var/nix/profiles/system` | NixOS intrinsic | **INTRINSIC** |
| `src/scripts/system/pre-rebuild-snapshot.sh` | 4 | `@POOL@/@DATASET@-pre-rebuild-` | Placeholder substitution via lib | **DESIGN** — substituted from Nix |
| `src/scripts/desktop/setup-autostart.sh` | 5–6 | `/etc/skel/.config/autostart` | Limits to skel path | **RESIDUAL** — could be env var |

---

## 3. Shell Scripts — Hardcoded Binary Names

| File | Line | Binary | Risk | Status |
|------|------|--------|------|--------|
| `src/scripts/desktop/init-desktop.sh` | 4–5 | `kquitapp6`, `kstart6`, `plasmashell` | KDE-specific | **INTRINSIC** — KDE desktop integration |
| `src/scripts/desktop/finalize.sh` | 6–8 | `lookandfeeltool`, `qdbus6`, `org.kde.breezedark.desktop`, `org.kde.KWin` | KDE-specific | **INTRINSIC** — KDE desktop integration |
| `src/scripts/build/iso-build.sh` | 18, 36–39 | `sudo`, `.#packages.x86_64-linux.iso-*` | Build script | **RESIDUAL** — could accept targets as args |

---

## 4. Module: `hardening.nix`

Originally had **zero options**. All values were hardcoded literals.

| Hardcoded Value | Status |
|-----------------|--------|
| `security.apparmor.enable = true` | **FIXED** → `cfg.apparmor.enable` |
| `security.apparmor.enableCache = true` | **FIXED** → `cfg.apparmor.enableCache` |
| `security.apparmor.packages = [ pkgs.apparmor-profiles ]` | **FIXED** → `cfg.apparmor.packages` |
| `security.protectKernelImage = true` | **FIXED** → `cfg.protectKernelImage` |
| `security.allowUserNamespaces = true` | **FIXED** → `cfg.allowUserNamespaces` |
| `security.lockKernelModules = false` | **FIXED** → `cfg.lockKernelModules` |
| `security.audit.enable = true` | **FIXED** → `cfg.audit.enable` |
| `security.audit.rules = [ ... ]` | **FIXED** → `cfg.audit.rules` |
| `boot.kernelParams = [ "slab_nomerge" ... ]` | **FIXED** → `cfg.kernelParams` |
| `systemd.services.avahi-daemon.enable = lib.mkDefault false` | **FIXED** → `cfg.disableServices` |
| `systemd.services.cups.enable = lib.mkDefault false` | **FIXED** → `cfg.disableServices` |
| `systemd.services.bluetooth.enable = lib.mkDefault false` | **FIXED** → `cfg.disableServices` |
| `DefaultTimeoutStopSec = "10s"` | **FIXED** → `cfg.systemdTimeoutStopSec` |
| `DefaultTimeoutStartSec = "30s"` | **FIXED** → `cfg.systemdTimeoutStartSec` |
| `DefaultDeviceTimeoutSec = "30s"` | **FIXED** → `cfg.systemdDeviceTimeoutSec` |

---

## 5. Module: `ssh.nix`

Additional options added for previously hardcoded SSH daemon settings:

| Hardcoded Value | Status |
|-----------------|--------|
| `KbdInteractiveAuthentication = false` | **FIXED** → `cfg.kbdInteractiveAuth` |
| `AuthenticationMethods = "publickey"` | **FIXED** → `cfg.authenticationMethods` |
| `UsePAM = false` | **FIXED** → `cfg.usePAM` |
| `LoginGraceTime = 30` | **FIXED** → `cfg.loginGraceTime` |
| `PermitTunnel = false` | **FIXED** → `cfg.permitTunnel` |
| `X11Forwarding = false` | **FIXED** → `cfg.x11Forwarding` |
| `ClientAliveInterval = 300` | **FIXED** → `cfg.clientAliveInterval` |
| `ClientAliveCountMax = 0` | **FIXED** → `cfg.clientAliveCountMax` |
| `HostKeyAlgorithms = "ssh-ed25519,rsa-sha2-512"` | **FIXED** → `cfg.hostKeyAlgorithms` |
| `Compression = "no"` | **FIXED** → `cfg.compression` |
| `bits = 4096` (RSA key) | **FIXED** → `cfg.rsaKeyBits` |
| `banaction = "nftables-multiport"` | **FIXED** → `cfg.fail2ban.banaction` |

---

## 6. Module: `nix.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `nix.package = pkgs.nixVersions.stable` | **FIXED** → `cfg.package` |
| `experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "ca-derivations" ]` | **FIXED** → `cfg.experimentalFeatures` |
| `auto-optimise-store = true` | **FIXED** → `cfg.autoOptimiseStore` |
| `nix.gc.automatic = true` | **FIXED** → `cfg.gc.automatic` |
| `nix.optimise.automatic = true` | **FIXED** → `cfg.optimise.automatic` |

---

## 7. Module: `boot.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `boot.loader.systemd-boot.enable = true` | **FIXED** → `cfg.enableSystemdBoot` |
| `boot.loader.efi.canTouchEfiVariables = true` | **FIXED** → `cfg.canTouchEfiVariables` |
| `boot.initrd.verbose = false` | **FIXED** → `cfg.initrdVerbose` |
| `boot.initrd.systemd.enable = true` | **FIXED** → `cfg.initrdSystemd` |

---

## 8. Module: `power.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `services.earlyoom.enableNotifications = true` | **FIXED** → `cfg.earlyoom.enableNotifications` |

---

## 9. Module: `zfs.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `services.zfs.trim.enable = true` | **FIXED** → `cfg.trim.enable` |
| `services.zfs.autoScrub.enable = true` | **FIXED** → `cfg.scrub.enable` |
| `services.zfs.autoSnapshot.enable = true` | **FIXED** → `cfg.snapshot.enable` |
| `services.sanoid.enable = true` | **FIXED** → `cfg.sanoid.enable` |

---

## 10. Module: `impermanence.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `environment.persistence."...".hideMounts = true` | **FIXED** → `cfg.hideMounts` |
| `fileSystems."...".fsType = "zfs"` (persist) | **FIXED** → `cfg.persistFsType` |
| `fileSystems."...".neededForBoot = true` (persist) | **FIXED** → `cfg.persistNeededForBoot` |
| `fileSystems."/home".fsType = "zfs"` | **FIXED** → `cfg.homeFsType` |
| `fileSystems."/home".neededForBoot = true` | **FIXED** → `cfg.homeNeededForBoot` |

---

## 11. Module: `disko.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `disk.main.device` default `"/dev/nvme0n1"` | **FIXED** — removed default; now required |
| Hardcoded dataset names and mountpoints | **FIXED** → `cfg.datasets` (attrs with mountpoints) |
| `boot.size = "1G"`, `boot.type = "EF00"` | **FIXED** → `cfg.bootSize`, `cfg.bootPartitionType` |
| `boot.content.format = "vfat"`, `boot.content.mountpoint = "/boot"` | **FIXED** → `cfg.bootFormat`, `cfg.bootMountpoint` |

---

## 12. Module: `firewall.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `udp dport 5353` | **FIXED** → `cfg.mdnsPort` |
| `udp dport { 67, 68 }` | **FIXED** → `cfg.dhcpPorts` |
| `log prefix "NF:DROP-INPUT: "` | **FIXED** → `cfg.inputLogPrefix` |
| `log prefix "NF:DROP-FORWARD: "` | **FIXED** → `cfg.forwardLogPrefix` |

---

## 13. Module: `dns.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `services.resolved.domains = [ "~." ]` | **FIXED** → `cfg.domains` |

---

## 14. Module: `base.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `networking.networkmanager.enable = true` | **FIXED** → `cfg.enableNetworkManager` |
| `networking.useDHCP = lib.mkDefault true` | **FIXED** → `cfg.useDHCP` |
| `networking.firewall.enable = false` | **FIXED** → `cfg.enableFirewall` |
| `services.avahi.publish.{enable,addresses,workstation,userServices}` | **FIXED** → all via `cfg.avahi.*` |
| `environment.systemPackages = [ networkmanagerapplet ... ]` | **FIXED** → `cfg.packages` |

---

## 15. Module: `pipewire.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `services.pipewire.{alsa,pulse,wireplumber}.enable = true` | **FIXED** → `cfg.enableAlsa`, `cfg.enablePulse`, `cfg.enableWireplumber` |
| `users.groups.audio = { }` | **FIXED** → `cfg.enableAudioGroup` |
| `environment.systemPackages = [ pulsemixer helvum ]` | **FIXED** → `cfg.packages` |

---

## 16. Module: `kde-minimal.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| SDDM enable, theme, numlock | **FIXED** → `cfg.enableSddm`, `cfg.sddmTheme`, `cfg.sddmAutoNumlock` |
| Plasma6 enable, Qt5 integration | **FIXED** → `cfg.enablePlasma6`, `cfg.enableQt5Integration` |
| Graphics enable, 32-bit | **FIXED** → `cfg.enableGraphics`, `cfg.enableGraphics32Bit` |
| XDG portal enable | **FIXED** → `cfg.enableXdgPortal` |
| Font packages and defaults | **FIXED** → `cfg.fontPackages`, font config options |

---

## 17. Module: `layout.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| Package list (plasma-desktop, kwin, etc.) | **FIXED** → `cfg.packages` |
| SDDM Wayland enable, Qt5 integration, polkit | **FIXED** → `cfg.enableSddmWayland`, `cfg.enableQt5Integration`, `cfg.enablePolkit` |
| Plasmarc theme name, wallpaper fill mode | **FIXED** → `cfg.plasmarcTheme`, `cfg.wallpaperFillMode` |

---

## 18. Module: `gpu.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `hardware.nvidia.modesetting.enable = true` | **FIXED** → `cfg.nvidia.modesetting` |
| `hardware.nvidia.powerManagement.enable = true` | **FIXED** → `cfg.nvidia.powerManagement` |
| `hardware.nvidia.powerManagement.finegrained = false` | **FIXED** → `cfg.nvidia.powerManagementFinegrained` |
| `hardware.nvidia.open = false` | **FIXED** → `cfg.nvidia.openDriver` |
| `hardware.nvidia.nvidiaSettings = false` | **FIXED** → `cfg.nvidia.nvidiaSettings` |
| `prime.offload.enableOffloadCmd = true` | **FIXED** → `cfg.nvidia.enableOffloadCmd` |
| `hardware.graphics.enable = true` | **FIXED** → `cfg.graphics.enable` |
| `hardware.graphics.enable32Bit = true` | **FIXED** → `cfg.graphics.enable32Bit` |
| Graphics extraPackages (intel-media-driver / libva-vdpau-driver) | **FIXED** → `cfg.graphics.extraPackages` |

---

## 19. Module: `cpu.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `hardware.cpu.intel.updateMicrocode = mkIf (vendor == "intel") true` | **FIXED** → `cfg.enableIntelMicrocode` |
| `hardware.cpu.amd.updateMicrocode = mkIf (vendor == "amd") true` | **FIXED** → `cfg.enableAmdMicrocode` |

---

## 20. Module: `locale.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `console.packages = with pkgs; [ terminus_font ]` | **FIXED** → `cfg.consoleFontPackages` |

---

## 21. Module: `microvm-host.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| `device = "zroot/root/microvm"` | **FIXED** → `cfg.zfsDataset` |
| `boot.kernelModules = [ "virtio" ... ]` | **FIXED** → `cfg.kernelModules` |
| `boot.initrd.kernelModules = [ "virtiofs" ]` | **FIXED** → `cfg.initrdKernelModules` |
| `microvm.host.enable = true` | **FIXED** → (wrapped in `mkIf cfg.enable`) |

---

## 22. Module: `orchestrator.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| Hardcoded `30` (healthcheck interval) | **FIXED** → `cfg.checkInterval` |
| Service Type, Restart, RestartSec, StateDirectory | **FIXED** → all via cfg options |

---

## 23. Module: `instance-pool.nix`

| Hardcoded Value | Status |
|-----------------|--------|
| Hardcoded `"512"` (PIDs limit) | **FIXED** → `cfg.pidsPerInstance` |
| Service Type, Restart, RestartSec | **FIXED** → `cfg.serviceType`, `cfg.serviceRestart`, `cfg.serviceRestartSec` |
| LimitNOFILE, LimitNPROC | **FIXED** → `cfg.serviceLimitNoFile`, `cfg.serviceLimitNProc` |

---

## 24. Guest Files

| File | Hardcoded Value | Status |
|------|-----------------|--------|
| `src/guests/example/instance.nix` | `"/tmp/.X11-unix/X0"`, `/run/user/${uidStr}/wayland-0` | **FIXED** → `cfg.x11Socket`, `cfg.waylandSocket` (computed default) |
| `src/guests/sandbox.nix` | `"/tmp/.X11-unix/X0"`, `source = "/home"` | **FIXED** → `cfg.x11Socket`, `cfg.homeSource`, `cfg.homeMountPoint`, `cfg.enablePipewire` |

---

## 25. Host-Specific Files (unchanged)

`src/hosts/flakeos/` files that remain hardcoded. These are per-host configurations and expected to contain literal values, but could be further parameterized:

| File | Hardcoded Value | Risk |
|------|-----------------|------|
| `hardware.nix` | Kernel modules, ZFS datasets (`zroot/root/*`), `max-jobs = 8`, `cpuFreqGovernor = "powersave"` | **Not portable** — tied to the specific machine |
| `default.nix` | `programs.zsh.enable = true`, `security.sudo.enable = true`, `users.users.root.openssh.authorizedKeys.keys = [ ]` | Host-specific; reflects local admin choices |
| `meta.nix` | `hostname = "flakeos"`, `username = "user"` | Expected per template; literal by nature |

---

## 26. Profiles (unchanged)

| File | Hardcoded Value | Risk |
|------|-----------------|------|
| `src/profiles/server.nix:16` | `services.openssh.enable = true` | Could be gated behind a flakeos option |
| `src/profiles/minimal.nix:17` | `services.openssh.enable = true` | Same |

---

## 27. Config Files (unchanged)

| File | Issue |
|------|-------|
| `src/config/security/nftables.conf` | **Dead file** — not referenced by any module. Firewall module uses inline nftables ruleset. Should be removed. |

---

## 28. lib/ — Design Intrinsic

| File | Notes |
|------|-------|
| `lib/hardware.nix` | Hardware database. Hardcoded values are data, not configuration. |
| `lib/spring.nix` | Framework defaults (bean definitions, systemd config). Parameterized via the DI container options. |

---

## 29. Known Bug

| Location | Issue |
|----------|-------|
| `src/module/security/firewall.nix:6` | `lanRanges` default uses `"192.168.0.0/24"` but should be `"192.168.0.0/16"` for typical home LANs. The dead `nftables.conf` correctly uses `/16`. |

---

## Summary

| Category | Fixed | Residual | Design/Intrinsic |
|----------|-------|----------|------------------|
| Shell script `${VAR:-default}` | 4 files (8 occ.) | — | — |
| Shell script hardware paths | — | 5 scripts | 2 scripts |
| Module hardcoded values | 22 modules | — | — |
| Hardware database (lib/) | — | — | 2 files |
| Host files | — | 3 files | — |
| Profiles | — | 2 lines | — |
| Dead config files | — | 1 file | — |
| Known bug | — | 1 (firewall.nix CIDR) | — |
