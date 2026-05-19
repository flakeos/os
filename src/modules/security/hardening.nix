{ config, lib, pkgs, ... }:
{
  security = {
    apparmor = {
      enable = true;
      enableCache = true;
      packages = [ pkgs.apparmor-profiles ];
    };
    protectKernelImage = true;
    allowUserNamespaces = true;
    lockKernelModules = false;
    wrappers = { };
    audit = {
      enable = true;
      rules = [
        "-w /etc/nixos -p wa -k nixos-config"
        "-w /nix/store -p wa -k nix-store"
        "-a exit,always -S execve -k process-exec"
        "-a exit,always -S mount -k mount"
      ];
    };
  };
  boot.kernelParams = [
    "quiet"
    "slab_nomerge"
    "init_on_alloc=1"
    "init_on_free=1"
    "page_alloc.shuffle=1"
    "pti=on"
    "vsyscall=none"
    "debugfs=off"
    "module.sig_enforce=1"
    "lockdown=confidentiality"
  ];
  systemd = {
    services = {
      avahi-daemon.enable = lib.mkDefault false;
      cups.enable = lib.mkDefault false;
      bluetooth.enable = lib.mkDefault false;
    };
    extraConfig = ''
      DefaultTimeoutStopSec=10s
      DefaultTimeoutStartSec=30s
      DefaultDeviceTimeoutSec=30s
    '';
  };
}
