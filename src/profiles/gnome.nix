{ lib, ... }:
with lib;
{
  flakeos = {
    desktop = {
      gnome.enable = mkDefault true;
      audio.enable = mkDefault true;
    };
    hardwareProfile = mkDefault "desktop";
  };
}
