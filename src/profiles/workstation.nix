{ config, lib, pkgs, ... }:
with lib;
{
  bora = {
    desktop = {
      kde.enable = mkDefault true;
      audio.enable = mkDefault true;
      layout.enable = mkDefault true;
    };
    hardwareProfile = mkDefault "desktop";
  };
}
