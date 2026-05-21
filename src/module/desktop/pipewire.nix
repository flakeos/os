{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.desktop.audio; in {
  options.flakeos.desktop.audio = {
    enable = mkOption { type = types.bool; description = "PipeWire audio system"; };
    enableAlsa = mkOption { type = types.bool; };
    enablePulse = mkOption { type = types.bool; };
    enableWireplumber = mkOption { type = types.bool; };
    enableAudioGroup = mkOption { type = types.bool; };
    packages = mkOption { type = types.listOf types.package; };
  };
  config = mkIf cfg.enable {
    flakeos.desktop.audio = {
      enableAlsa = mkDefault true;
      enablePulse = mkDefault true;
      enableWireplumber = mkDefault true;
      enableAudioGroup = mkDefault true;
      packages = mkDefault (with pkgs; [ pulsemixer helvum ]);
    };
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
