{ config, lib, pkgs, ... }:
with lib;
let
  hwLib = import ../../../../lib/hardware.nix { inherit lib; };
  hwProfile = config.bora.hardwareProfile or "desktop";
  profileCfg = hwLib.profileOpts.${hwProfile} or hwLib.profileOpts.desktop;
in {
  options.bora.hardwareProfile = mkOption {
    type = types.enum [ "desktop" "laptop" "server" ];
    default = "desktop";
    description = "Hardware profile for power/mitigation tuning";
  };
  config = profileCfg;
}
