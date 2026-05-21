{ pkgs, lib, ... }:
with lib;
{
  options.flakeos.guest.sandbox = {
    enable = mkEnableOption "Sandbox guest template";
    mem = mkOption { type = types.int; default = 2048; };
    vcpu = mkOption { type = types.int; default = 2; };
    packages = mkOption { type = types.listOf types.package; default = with pkgs; [ firefox chromium ]; };
    hostUid = mkOption { type = types.int; default = 1000; };
  };

  config = mkIf config.flakeos.guest.sandbox.enable
    (
      let
        uidStr = toString config.flakeos.guest.sandbox.hostUid;
      in
      {
        microvm = {
          guest.enable = true;
          interfaces = [{
            type = "bridge";
            host = "microvm";
          }];
          shares = [{
            source = "/home";
            mountPoint = "/mnt/home";
            type = "virtiofs";
          }];
          sockets = [
            "/tmp/.X11-unix/X0"
            "/run/user/${uidStr}/wayland-0"
            "/run/user/${uidStr}/pipewire-0"
            "/run/user/${uidStr}/pulse"
          ];
          mem = config.flakeos.guest.sandbox.mem;
          vcpu = config.flakeos.guest.sandbox.vcpu;
        };
        services.pipewire.enable = true;
        environment.systemPackages = config.flakeos.guest.sandbox.packages;
        system.stateVersion = "25.11";
      }
    );
}
