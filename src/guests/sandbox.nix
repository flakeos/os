{ pkgs, lib, ... }:
with lib;
let cfg = config.flakeos.guest.sandbox; in {
  options.flakeos.guest.sandbox = {
    enable = mkOption { type = types.bool; };
    mem = mkOption { type = types.int; };
    vcpu = mkOption { type = types.int; };
    packages = mkOption { type = types.listOf types.package; };
    hostUid = mkOption { type = types.int; };
    homeSource = mkOption { type = types.str; };
    homeMountPoint = mkOption { type = types.str; };
    x11Socket = mkOption { type = types.str; };
    enablePipewire = mkOption { type = types.bool; };
  };

  config = mkIf cfg.enable {
    flakeos.guest.sandbox = {
      mem = mkDefault 2048;
      vcpu = mkDefault 2;
      packages = mkDefault (with pkgs; [ firefox chromium ]);
      hostUid = mkDefault 1000;
      homeSource = mkDefault "/home";
      homeMountPoint = mkDefault "/mnt/home";
      x11Socket = mkDefault "/tmp/.X11-unix/X0";
      enablePipewire = mkDefault true;
    };
    microvm = {
      guest.enable = true;
      interfaces = [{
        type = "bridge";
        host = "microvm";
      }];
      shares = [{
        source = cfg.homeSource;
        mountPoint = cfg.homeMountPoint;
        type = "virtiofs";
      }];
      sockets = [
        cfg.x11Socket
        "/run/user/${toString cfg.hostUid}/wayland-0"
        "/run/user/${toString cfg.hostUid}/pipewire-0"
        "/run/user/${toString cfg.hostUid}/pulse"
      ];
      mem = cfg.mem;
      vcpu = cfg.vcpu;
    };
    services.pipewire.enable = cfg.enablePipewire;
    environment.systemPackages = cfg.packages;
  };
}
