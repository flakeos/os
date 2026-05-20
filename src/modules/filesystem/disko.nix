{ config, lib, ... }:
with lib;
let cfg = config.bora.filesystem.disko; in {
  options.bora.filesystem.disko = {
    enable = mkEnableOption "disko declarative partitioning";
    disk = mkOption {
      type = types.str;
      default = "/dev/nvme0n1";
      description = "Target disk device for partitioning";
    };
    zfsPool = mkOption {
      type = types.str;
      default = "zroot";
      description = "ZFS pool name";
    };
  };
  config = mkIf cfg.enable {
    disko.devices = {
      disk.main = {
        type = "disk";
        device = cfg.disk;
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = cfg.zfsPool;
              };
            };
          };
        };
      };
      zpool.${cfg.zfsPool} = {
        type = "zpool";
        mode = "";
        datasets = {
          "root" = { type = "zfs_fs"; mountpoint = "/"; };
          "root/nix" = { type = "zfs_fs"; mountpoint = "/nix"; };
          "root/home" = { type = "zfs_fs"; mountpoint = "/home"; };
          "root/persist" = { type = "zfs_fs"; mountpoint = "/persist"; };
          "root/var" = { type = "zfs_fs"; mountpoint = "/var"; };
          "root/tmp" = { type = "zfs_fs"; mountpoint = "/tmp"; };
        };
      };
    };
  };
}
