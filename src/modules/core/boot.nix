{ config, lib, pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
      timeout = lib.mkDefault 3;
    };
    kernelParams = [
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
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      systemd.enable = true;
    };
    supportedFilesystems = [ "zfs" "btrfs" "ntfs" "exfat" "vfat" "xfs" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    cpu = {
      intel.updateMicrocode = lib.mkDefault true;
      amd.updateMicrocode = lib.mkDefault true;
    };
  };
}
