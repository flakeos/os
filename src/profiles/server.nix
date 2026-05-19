{ config, lib, pkgs, ... }:
with lib;
{
  bora = {
    desktop.kde.enable = mkDefault false;
    desktop.audio.enable = mkDefault false;
    desktop.layout.enable = mkDefault false;
    containers.instancePool.enable = mkDefault false;
    hardwareProfile = mkDefault "server";
    hardware.cpuVendor = mkDefault "intel";
    hardware.gpuVendor = mkDefault "intel";
  };

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  systemd.services.sshd.wantedBy = [ "multi-user.target" ];
}
