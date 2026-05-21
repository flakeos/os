{ lib, config, ... }:
with lib;
let cfg = config.flakeos.guest.example; in {
  options.flakeos.guest.example = {
    enable = mkOption { type = types.bool; };
    mem = mkOption { type = types.int; };
    vcpu = mkOption { type = types.int; };
    hostUid = mkOption { type = types.int; };
    workspaceDir = mkOption { type = types.str; };
    x11Socket = mkOption { type = types.str; };
    waylandSocket = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    flakeos.guest.example = {
      mem = mkDefault 256;
      vcpu = mkDefault 1;
      hostUid = mkDefault 1000;
      workspaceDir = mkDefault "/var/lib/instance-pool/workspaces";
      x11Socket = mkDefault "/tmp/.X11-unix/X0";
      waylandSocket = mkDefault "/run/user/${toString cfg.hostUid}/wayland-0";
    };
    microvm = {
      guest.enable = true;
      interfaces = [{
        type = "bridge";
        host = "microvm";
      }];
      shares = [{
        source = cfg.workspaceDir;
        mountPoint = "/workspace";
        type = "virtiofs";
      }];
      sockets = [
        cfg.x11Socket
        cfg.waylandSocket
      ];
      mem = cfg.mem;
      vcpu = cfg.vcpu;
    };
  };
}
