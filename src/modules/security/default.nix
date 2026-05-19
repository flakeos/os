{ config, lib, pkgs, ... }:
{
  imports = [
    ./firewall.nix
    ./hardening.nix
    ./ssh.nix
  ];
}
