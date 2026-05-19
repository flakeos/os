{ config, lib, pkgs, ... }:
{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 20;
    };
    efi.canTouchEfiVariables = true;
    timeout = lib.mkDefault 3;
  };
  boot.kernelParams = [
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
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;
  boot.supportedFilesystems = [ "zfs" "btrfs" "ntfs" "exfat" "vfat" "xfs" ];
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
}
