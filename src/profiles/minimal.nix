{ config, lib, pkgs, ... }:
with lib;
{
  bora = {
    desktop.kde.enable = mkDefault false;
    desktop.audio.enable = mkDefault false;
    desktop.layout.enable = mkDefault false;
    hardwareProfile = mkDefault "server";
    hardware.cpuVendor = mkDefault "intel";
    hardware.gpuVendor = mkDefault "intel";
  };

  services.openssh.enable = true;
}
