{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ "${modulesPath}/profiles/minimal.nix" ];

  microvm.guest.enable = true;

  microvm.interfaces = [{
    type = "bridge";
    host = "microvm";
  }];

  microvm.shares = [{
    source = "/home";
    mountPoint = "/mnt/home";
    type = "virtiofs";
  }];

  microvm.sockets = [
    "/tmp/.X11-unix/X0"
    "/run/user/1000/wayland-0"
    "/run/user/1000/pipewire-0"
    "/run/user/1000/pulse"
  ];

  microvm.mem = 2048;
  microvm.vcpu = 2;

  services.pipewire.enable = true;

  environment.systemPackages = with pkgs; [
    firefox chromium
  ];

  system.stateVersion = "24.11";
}
