{ lib, ... }:
with lib;
{
  flakeos = {
    desktop = {
      kde.enable = mkDefault false;
      audio.enable = mkDefault false;
      layout.enable = mkDefault false;
    };
    hardwareProfile = mkDefault "server";
    hardware = {
      cpuVendor = mkDefault "intel";
      gpuVendor = mkDefault "intel";
    };
  };

  services.openssh.enable = true;
}
