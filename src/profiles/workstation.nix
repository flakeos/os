{ config, lib, pkgs, ... }:
with lib;
{
  bora = {
    desktop = {
      kde.enable = mkDefault true;
      audio.enable = mkDefault true;
      layout.enable = mkDefault true;
    };
    hardware.cpuVendor = mkDefault "intel";
    hardware.gpuVendor = mkDefault "amd";
    hardwareProfile = mkDefault "desktop";
  };
}
