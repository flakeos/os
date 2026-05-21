{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.core.boot; in {
  options.flakeos.core.boot = {
    enableSystemdBoot = mkOption { type = types.bool; default = true; };
    canTouchEfiVariables = mkOption { type = types.bool; default = true; };
    configurationLimit = mkOption { type = types.int; default = 20; };
    timeout = mkOption { type = types.int; default = 3; };
    kernelParams = mkOption {
      type = types.listOf types.str;
      default = [
        "quiet"
        "splash"
        "mitigations=auto"
        "random.trust_cpu=off"
        "random.trust_bootloader=off"
        "slab_nomerge"
        "init_on_alloc=1"
        "init_on_free=1"
        "page_alloc.shuffle=1"
        "pti=on"
        "vsyscall=none"
        "debugfs=off"
      ];
    };
    consoleLogLevel = mkOption { type = types.int; default = 0; };
    initrdVerbose = mkOption { type = types.bool; default = false; };
    initrdSystemd = mkOption { type = types.bool; default = true; };
    supportedFilesystems = mkOption { type = types.listOf types.str; default = [ "zfs" "btrfs" "ntfs" "exfat" "vfat" "xfs" ]; };
    kernelPackage = mkOption { type = types.package; default = pkgs.linuxPackages_latest; };
    enableRedistributableFirmware = mkOption { type = types.bool; default = true; };
    enableAllFirmware = mkOption { type = types.bool; default = true; };
    enableIntelMicrocode = mkOption { type = types.bool; default = true; };
    enableAmdMicrocode = mkOption { type = types.bool; default = true; };
  };
  config = {
    boot = {
      loader = {
        systemd-boot = {
          enable = cfg.enableSystemdBoot;
          configurationLimit = cfg.configurationLimit;
        };
        efi.canTouchEfiVariables = cfg.canTouchEfiVariables;
        timeout = mkDefault cfg.timeout;
      };
      kernelParams = cfg.kernelParams;
      consoleLogLevel = cfg.consoleLogLevel;
      initrd = {
        verbose = cfg.initrdVerbose;
        systemd.enable = cfg.initrdSystemd;
      };
      supportedFilesystems = cfg.supportedFilesystems;
      kernelPackages = mkDefault cfg.kernelPackage;
    };
    hardware = {
      enableRedistributableFirmware = cfg.enableRedistributableFirmware;
      enableAllFirmware = cfg.enableAllFirmware;
      cpu = {
        intel.updateMicrocode = mkDefault cfg.enableIntelMicrocode;
        amd.updateMicrocode = mkDefault cfg.enableAmdMicrocode;
      };
    };
  };
}
