{ config, lib, pkgs, ... }:
with lib;
{
  bora = {
    desktop.kde.enable = mkDefault true;
    desktop.audio.enable = mkDefault true;
    desktop.layout.enable = mkDefault true;
    hardware.cpuVendor = mkDefault "intel";
    hardware.gpuVendor = mkDefault "amd";
    hardwareProfile = mkDefault "desktop";
  };
}
