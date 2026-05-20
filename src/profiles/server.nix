{ lib, ... }:
with lib;
{
  bora = {
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
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  systemd.services.sshd.wantedBy = [ "multi-user.target" ];
}
