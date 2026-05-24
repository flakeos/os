{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.core.boot; in {
  options.flakeos.core.boot = {
    enable = mkOption { type = types.bool; };
    enableSystemdBoot = mkOption { type = types.bool; };
    canTouchEfiVariables = mkOption { type = types.bool; };
    configurationLimit = mkOption { type = types.int; };
    timeout = mkOption { type = types.int; };
    kernelParams = mkOption { type = types.listOf types.str; };
    consoleLogLevel = mkOption { type = types.int; };
    initrdVerbose = mkOption { type = types.bool; };
    initrdSystemd = mkOption { type = types.bool; };
    supportedFilesystems = mkOption { type = types.listOf types.str; };
    kernelPackage = mkOption { type = types.package; };
    enableRedistributableFirmware = mkOption { type = types.bool; };
    enableAllFirmware = mkOption { type = types.bool; };
    enableIntelMicrocode = mkOption { type = types.bool; };
    enableAmdMicrocode = mkOption { type = types.bool; };
  };
  config = mkIf cfg.enable {
    flakeos.core.boot = {
      enable = mkDefault true;
      enableSystemdBoot = mkDefault true;
      canTouchEfiVariables = mkDefault true;
      configurationLimit = mkDefault 20;
      timeout = mkDefault 3;
      kernelParams = mkDefault [
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
      consoleLogLevel = mkDefault 0;
      initrdVerbose = mkDefault false;
      initrdSystemd = mkDefault true;
      supportedFilesystems = mkDefault [ "zfs" "btrfs" "ntfs" "exfat" "vfat" "xfs" ];
      kernelPackage = mkDefault pkgs.linuxPackages_latest;
      enableRedistributableFirmware = mkDefault true;
      enableAllFirmware = mkDefault true;
      enableIntelMicrocode = mkDefault true;
      enableAmdMicrocode = mkDefault true;
    };
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
