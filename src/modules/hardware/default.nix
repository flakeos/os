{ config, lib, pkgs, ... }:
{
  imports = [
    ./cpu.nix
    ./gpu.nix
    ./platform.nix
  ];
}
