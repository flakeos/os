{ lib, ... }:
with lib;
{
  flakeos = {
    desktop = {
      kde.enable = mkDefault false;
      audio.enable = mkDefault false;
      hyprland.enable = mkDefault false;
      gnome.enable = mkDefault false;
    };
    security = {
      ssh.enable = mkDefault true;
      hardening.enable = mkDefault false;
      firewall.enable = mkDefault false;
    };
    containers = {
      instancePool.enable = mkDefault false;
      microvm.enable = mkDefault false;
    };
    orchestrator.enable = mkDefault false;
    core = {
      boot.enable = mkDefault true;
      nix.enable = mkDefault true;
      locale.enable = mkDefault true;
      power.enable = mkDefault false;
      sysctl.enable = mkDefault false;
    };
    hardware.enable = mkDefault true;
    network = {
      base.enable = mkDefault false;
      dns.enable = mkDefault false;
    };
    filesystem = {
      disko.enable = mkDefault false;
    };
    hardwareProfile = mkDefault "server";
    hardware = {
      cpuVendor = mkDefault "intel";
      gpuVendor = mkDefault "intel";
    };
  };
}
