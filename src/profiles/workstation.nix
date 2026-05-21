{ lib, ... }:
with lib;
{
  flakeos = {
    desktop = {
      kde.enable = mkDefault true;
      audio.enable = mkDefault true;
    };
    hardwareProfile = mkDefault "desktop";
  };
}
