{ config, lib, hardwareDB, ... }:
with lib;
let
  inherit (hardwareDB) profileOpts;
in
{
  options.flakeos.hardwareProfile = mkOption {
    type = types.enum [ "desktop" "laptop" "server" ];
    description = "Hardware profile for power/mitigation tuning";
  };
  config = mkMerge [
    (mkIf (config.flakeos.hardwareProfile == "desktop") profileOpts.desktop)
    (mkIf (config.flakeos.hardwareProfile == "laptop") profileOpts.laptop)
    (mkIf (config.flakeos.hardwareProfile == "server") profileOpts.server)
  ];
}
