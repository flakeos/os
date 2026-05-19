{ config, lib, pkgs, ... }:
{
  imports = [
    ./zfs.nix
    ./impermanence.nix
    ./disko.nix
  ];
}
