{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.desktop.audio;
in
{
  options.flakeos.desktop.audio = {
    enable = mkEnableOption "PipeWire audio system";
  };
  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    users.groups.audio = { };
    environment.systemPackages = with pkgs; [
      pulsemixer
      helvum
    ];
  };
}
