{ config, lib, modulesPath, ... }:
let
  zfsCfg = config.flakeos.filesystem.zfs;
in

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
      kernelModules = [ "zfs" ];
    };
    kernelModules = [ "kvm-amd" "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = { device = "${zfsCfg.zfsPool}/root"; fsType = "zfs"; };
    "/nix" = { device = "${zfsCfg.zfsPool}/root/nix"; fsType = "zfs"; };
    "/home" = { device = "${zfsCfg.zfsPool}/root/home"; fsType = "zfs"; };
    "/var" = { device = "${zfsCfg.zfsPool}/root/var"; fsType = "zfs"; };
    "/tmp" = { device = "${zfsCfg.zfsPool}/root/tmp"; fsType = "zfs"; };
    "/boot" = { device = zfsCfg.bootDevice; fsType = "vfat"; };
  };

  swapDevices = [ ];

  nix.settings.max-jobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
