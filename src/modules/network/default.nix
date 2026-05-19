{ config, lib, pkgs, ... }:
{
  imports = [
    ./base.nix
    ./dns.nix
  ];
}
