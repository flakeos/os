{ lib, ... }:
with lib;
{
  flakeos = {
    desktop = {
      kde.enable = mkDefault false;
      audio.enable = mkDefault false;
    };
    containers.instancePool.enable = mkDefault false;
    security.ssh.enable = mkDefault true;
    core = {
      boot.enable = mkDefault true;
      nix.enable = mkDefault true;
      locale.enable = mkDefault true;
    };
    hardware.enable = mkDefault true;
    hardwareProfile = mkDefault "server";
    hardware.cpuVendor = mkDefault "intel";
    hardware.gpuVendor = mkDefault "intel";
  };
}
