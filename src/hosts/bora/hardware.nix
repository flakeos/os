{ config, lib, modulesPath, ... }:
let
  fsCfg = config.bora.filesystem;
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
    "/" = { device = "zroot/root"; fsType = "zfs"; };
    "/nix" = { device = "zroot/root/nix"; fsType = "zfs"; };
    "/home" = { device = "zroot/root/home"; fsType = "zfs"; };
    "/var" = { device = "zroot/root/var"; fsType = "zfs"; };
    "/tmp" = { device = "zroot/root/tmp"; fsType = "zfs"; };
    "/boot" = { device = fsCfg.bootDevice; fsType = "vfat"; };
  };

  swapDevices = [ ];

  nix.settings.max-jobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
