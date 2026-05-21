{ lib, ... }:
with lib;
{
  flakeos = {
    desktop = {
      kde.enable = mkDefault false;
      audio.enable = mkDefault false;
    };
    security.ssh.enable = mkDefault true;
    hardwareProfile = mkDefault "server";
    hardware = {
      cpuVendor = mkDefault "intel";
      gpuVendor = mkDefault "intel";
    };
  };
}
