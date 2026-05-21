{ lib, ... }:
with lib;
{
  flakeos = {
    desktop = {
      kde.enable = mkDefault false;
      audio.enable = mkDefault false;
      layout.enable = mkDefault false;
    };
    containers.instancePool.enable = mkDefault false;
    hardwareProfile = mkDefault "server";
    hardware.cpuVendor = mkDefault "intel";
    hardware.gpuVendor = mkDefault "intel";
  };

  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = [ "multi-user.target" ];
}
