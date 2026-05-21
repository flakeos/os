{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.security.hardening; in {
  options.flakeos.security.hardening = {
    enable = mkEnableOption "system hardening";
    apparmor = {
      enable = mkOption { type = types.bool; default = true; };
      enableCache = mkOption { type = types.bool; default = true; };
      packages = mkOption { type = types.listOf types.package; default = [ pkgs.apparmor-profiles ]; };
    };
    protectKernelImage = mkOption { type = types.bool; default = true; };
    allowUserNamespaces = mkOption { type = types.bool; default = true; };
    lockKernelModules = mkOption { type = types.bool; default = false; };
    audit = {
      enable = mkOption { type = types.bool; default = true; };
      rules = mkOption {
        type = types.listOf types.str;
        default = [
          "-w /etc/nixos -p wa -k nixos-config"
          "-w /nix/store -p wa -k nix-store"
          "-a exit,always -S execve -k process-exec"
          "-a exit,always -S mount -k mount"
        ];
      };
    };
    kernelParams = mkOption {
      type = types.listOf types.str;
      default = [
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
    };
    disableServices = mkOption {
      type = types.listOf types.str;
      default = [ "avahi-daemon" "cups" "bluetooth" ];
    };
    systemdTimeoutStopSec = mkOption { type = types.str; default = "10s"; };
    systemdTimeoutStartSec = mkOption { type = types.str; default = "30s"; };
    systemdDeviceTimeoutSec = mkOption { type = types.str; default = "30s"; };
  };
  config = mkIf cfg.enable {
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
