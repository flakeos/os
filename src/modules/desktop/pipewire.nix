{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.bora.desktop.audio;
in {
  options.bora.desktop.audio = {
    enable = mkEnableOption "PipeWire audio system";
    lowLatency = mkOption {
      type = types.bool;
      default = false;
      description = "Enable low-latency audio config";
    };
  };
  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = cfg.lowLatency;
      wireplumber.enable = true;
      extraConfig = mkIf cfg.lowLatency {
        "10-low-latency" = {
          context.properties = {
            default.clock.rate = 48000;
            default.clock.quantum = 64;
            default.clock.min-quantum = 32;
            default.clock.max-quantum = 256;
          };
        };
      };
    };
    security.rtkit.enable = cfg.lowLatency;
    users.groups.audio = { };
    environment.systemPackages = with pkgs; [
      pulsemixer
      helvum
    ];
  };
}
