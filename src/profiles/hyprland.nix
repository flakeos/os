{ lib, ... }:
with lib;
{
  flakeos = {
    desktop = {
      hyprland.enable = mkDefault true;
      audio.enable = mkDefault true;
    };
    hardwareProfile = mkDefault "desktop";
    hardware.cpuVendor = mkDefault "intel";
    hardware.gpuVendor = mkDefault "amd";
  };
}
