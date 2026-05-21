{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.security.hardening; in {
  options.flakeos.security.hardening = {
    enable = mkOption { type = types.bool; };
    apparmor = {
      enable = mkOption { type = types.bool; };
      enableCache = mkOption { type = types.bool; };
      packages = mkOption { type = types.listOf types.package; };
    };
    protectKernelImage = mkOption { type = types.bool; };
    allowUserNamespaces = mkOption { type = types.bool; };
    lockKernelModules = mkOption { type = types.bool; };
    audit = {
      enable = mkOption { type = types.bool; };
      rules = mkOption { type = types.listOf types.str; };
    };
    kernelParams = mkOption { type = types.listOf types.str; };
    disableServices = mkOption { type = types.listOf types.str; };
    systemdTimeoutStopSec = mkOption { type = types.str; };
    systemdTimeoutStartSec = mkOption { type = types.str; };
    systemdDeviceTimeoutSec = mkOption { type = types.str; };
  };
  config = mkIf cfg.enable {
    flakeos.security.hardening = {
      apparmor = {
        enable = mkDefault true;
        enableCache = mkDefault true;
        packages = mkDefault [ pkgs.apparmor-profiles ];
      };
      protectKernelImage = mkDefault true;
      allowUserNamespaces = mkDefault true;
      lockKernelModules = mkDefault false;
      audit = {
        enable = mkDefault true;
        rules = mkDefault [
          "-w /etc/nixos -p wa -k nixos-config"
          "-w /nix/store -p wa -k nix-store"
          "-a exit,always -S execve -k process-exec"
          "-a exit,always -S mount -k mount"
        ];
      };
      kernelParams = mkDefault [
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
      disableServices = mkDefault [ "avahi-daemon" "cups" "bluetooth" ];
      systemdTimeoutStopSec = mkDefault "10s";
      systemdTimeoutStartSec = mkDefault "30s";
      systemdDeviceTimeoutSec = mkDefault "30s";
    };
    security = {
      apparmor = {
        enable = cfg.apparmor.enable;
        enableCache = cfg.apparmor.enableCache;
        packages = cfg.apparmor.packages;
      };
      protectKernelImage = cfg.protectKernelImage;
      allowUserNamespaces = cfg.allowUserNamespaces;
      lockKernelModules = cfg.lockKernelModules;
      wrappers = { };
      audit = {
        enable = cfg.audit.enable;
        rules = cfg.audit.rules;
      };
    };
    boot.kernelParams = cfg.kernelParams;
    systemd = {
      services = builtins.listToAttrs (map
        (name:
          { name = name; value = { enable = lib.mkDefault false; }; }
        )
        cfg.disableServices);
      settings.Manager = {
        DefaultTimeoutStopSec = cfg.systemdTimeoutStopSec;
        DefaultTimeoutStartSec = cfg.systemdTimeoutStartSec;
        DefaultDeviceTimeoutSec = cfg.systemdDeviceTimeoutSec;
      };
    };
  };
}
