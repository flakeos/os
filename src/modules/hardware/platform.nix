{ config, lib, hardwareDB, ... }:
with lib;
let
  inherit (hardwareDB) profileOpts;
in
{
  options.bora.hardwareProfile = mkOption {
    type = types.enum [ "desktop" "laptop" "server" ];
    default = "desktop";
    description = "Hardware profile for power/mitigation tuning";
  };
  config = mkMerge [
    (mkIf (config.bora.hardwareProfile == "desktop") profileOpts.desktop)
    (mkIf (config.bora.hardwareProfile == "laptop") profileOpts.laptop)
    (mkIf (config.bora.hardwareProfile == "server") profileOpts.server)
  ];
}
