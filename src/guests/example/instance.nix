{ lib, modulesPath, config, ... }:
with lib;
{
  options.flakeos.guest.example = {
    enable = mkEnableOption "Example instance guest";
    mem = mkOption { type = types.int; default = 256; };
    vcpu = mkOption { type = types.int; default = 1; };
    hostUid = mkOption { type = types.int; default = 1000; };
    workspaceDir = mkOption { type = types.str; default = "/var/lib/instance-pool/workspaces"; };
  };

  config = mkIf config.flakeos.guest.example.enable
    (let uidStr = toString config.flakeos.guest.example.hostUid; in {
      microvm = {
        guest.enable = true;
        interfaces = [{
          type = "bridge";
          host = "microvm";
        }];
        shares = [{
          source = config.flakeos.guest.example.workspaceDir;
          mountPoint = "/workspace";
          type = "virtiofs";
        }];
        sockets = [
          "/tmp/.X11-unix/X0"
          "/run/user/${uidStr}/wayland-0"
        ];
        mem = config.flakeos.guest.example.mem;
        vcpu = config.flakeos.guest.example.vcpu;
      };
      system.stateVersion = "25.11";
    });
}
