{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.desktop.audio; in {
  options.flakeos.desktop.audio = {
    enable = mkEnableOption "PipeWire audio system";
    enableAlsa = mkOption { type = types.bool; default = true; };
    enablePulse = mkOption { type = types.bool; default = true; };
    enableWireplumber = mkOption { type = types.bool; default = true; };
    enableAudioGroup = mkOption { type = types.bool; default = true; };
    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ pulsemixer helvum ];
    };
  };
  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = cfg.enableAlsa;
      pulse.enable = cfg.enablePulse;
      wireplumber.enable = cfg.enableWireplumber;
    };
    users.groups.audio = mkIf cfg.enableAudioGroup { };
    environment.systemPackages = cfg.packages;
  };
}
