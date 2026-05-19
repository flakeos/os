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
      source = "/home";
      mountPoint = "/mnt/home";
      type = "virtiofs";
    }];
    sockets = [
      "/tmp/.X11-unix/X0"
      "/run/user/1000/wayland-0"
      "/run/user/1000/pipewire-0"
      "/run/user/1000/pulse"
    ];
    mem = 2048;
    vcpu = 2;
  };

  services.pipewire.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    chromium
  ];

  system.stateVersion = "25.11";
}
