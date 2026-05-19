{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./workstation.nix
  ];

  bora = {
    containers.instancePool.enable = mkDefault false;
    hardware.cpuVendor = mkDefault "amd";
    hardware.gpuVendor = mkDefault "nvidia";
    hardwareProfile = mkDefault "desktop";
  };

  environment.systemPackages = with pkgs; [
    gcc
    clang
    nodejs
    python3
    rustc
    cargo
    go
    nginx
  ];
}
