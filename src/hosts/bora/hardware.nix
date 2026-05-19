{ config, lib, pkgs, modulesPath, ... }:
let
  fsCfg = config.bora.filesystem;
in

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "zfs" ];
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = { device = "zroot/root"; fsType = "zfs"; };
  fileSystems."/nix" = { device = "zroot/root/nix"; fsType = "zfs"; };
  fileSystems."/home" = { device = "zroot/root/home"; fsType = "zfs"; };
  fileSystems."/var" = { device = "zroot/root/var"; fsType = "zfs"; };
  fileSystems."/tmp" = { device = "zroot/root/tmp"; fsType = "zfs"; };
  fileSystems."/boot" = { device = fsCfg.bootDevice; fsType = "vfat"; };

  swapDevices = [ ];

  nix.settings.max-jobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
