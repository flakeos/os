{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ "${modulesPath}/profiles/minimal.nix" ];

  microvm = {
    guest.enable = true;
    interfaces = [{
      type = "bridge";
      host = "microvm";
    }];
    shares = [{
      source = "/var/lib/instance-pool/workspaces";
      mountPoint = "/workspace";
      type = "virtiofs";
    }];
    sockets = [
      "/tmp/.X11-unix/X0"
      "/run/user/1000/wayland-0"
    ];
    mem = 256;
    vcpu = 1;
  };

  system.stateVersion = "25.11";
}
