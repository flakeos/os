{ config, lib, pkgs, ... }:
{
  imports = [
    ./microvm-host.nix
    ./orchestrator.nix
    ./instance-pool.nix
  ];
}
