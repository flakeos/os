{ config, lib, pkgs, hardwareDB, ... }:
{
  imports = [
    ./cpu.nix
    ./gpu.nix
    ./platform.nix
  ];
}
