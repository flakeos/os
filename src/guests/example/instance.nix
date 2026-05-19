{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ "${modulesPath}/profiles/minimal.nix" ];

  microvm.guest.enable = true;

  microvm.interfaces = [{
    type = "bridge";
    host = "microvm";
  }];

  microvm.shares = [{
    source = "/var/lib/instance-pool/workspaces";
    mountPoint = "/workspace";
    type = "virtiofs";
  }];

  microvm.sockets = [
    "/tmp/.X11-unix/X0"
    "/run/user/1000/wayland-0"
  ];

  microvm.mem = 256;
  microvm.vcpu = 1;

  system.stateVersion = "24.11";
}
