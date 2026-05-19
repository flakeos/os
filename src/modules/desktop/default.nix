{ config, lib, pkgs, ... }:
{
  imports = [
    ./kde-minimal.nix
    ./pipewire.nix
    ./maclike.nix
  ];
}
