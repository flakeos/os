{ config, lib, pkgs, ... }:
with lib;
{
  microvm = {
    host = {
      enable = true;
      socketVM = true;
      network = {
        enable = true;
        nat = true;
        subnet = "10.100.0.0/24";
      };
      balloonMem = 512;
      balloonMemMax = 65536;
      store = {
        backend = "zfs";
        dir = "/var/lib/microvm";
      };
    };
  };
  fileSystems."/var/lib/microvm" = {
    device = "zroot/root/microvm";
    fsType = "zfs";
    neededForBoot = true;
  };
  boot.kernelModules = [ "virtio" "virtio_net" "virtio_blk" "virtiofs" "virtio_gpu" ];
  boot.initrd.kernelModules = [ "virtiofs" ];
  users.groups.microvm = { };
}
