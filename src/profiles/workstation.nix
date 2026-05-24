{ lib, ... }:
with lib;
{
  flakeos = {
    desktop = {
      kde.enable = mkDefault true;
      audio.enable = mkDefault true;
    };
    core = {
      boot.enable = mkDefault true;
      nix.enable = mkDefault true;
      locale.enable = mkDefault true;
    };
    hardware.enable = mkDefault true;
    hardwareProfile = mkDefault "desktop";
    hardware.cpuVendor = mkDefault "intel";
    hardware.gpuVendor = mkDefault "amd";
  };
}
