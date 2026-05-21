{ config, lib, ... }:
with lib;
let cfg = config.flakeos.filesystem.disko; in {
  options.flakeos.filesystem.disko = {
    enable = mkEnableOption "disko declarative partitioning";
    disk = mkOption { type = types.str; };
    zfsPool = mkOption { type = types.str; default = "zroot"; };
    bootSize = mkOption { type = types.str; default = "1G"; };
    bootPartitionType = mkOption { type = types.str; default = "EF00"; };
    bootFormat = mkOption { type = types.str; default = "vfat"; };
    bootMountpoint = mkOption { type = types.str; default = "/boot"; };
    zfsSize = mkOption { type = types.str; default = "100%"; };
    datasets = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          mountpoint = mkOption { type = types.str; };
        };
      });
      default = {
        "root" = { mountpoint = "/"; };
        "root/nix" = { mountpoint = "/nix"; };
        "root/home" = { mountpoint = "/home"; };
        "root/persist" = { mountpoint = "/persist"; };
        "root/var" = { mountpoint = "/var"; };
        "root/tmp" = { mountpoint = "/tmp"; };
      };
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
              size = cfg.bootSize;
              type = cfg.bootPartitionType;
              content = {
                type = "filesystem";
                format = cfg.bootFormat;
                mountpoint = cfg.bootMountpoint;
              };
            };
            zfs = {
              size = cfg.zfsSize;
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
        datasets = builtins.mapAttrs
          (_name: ds: {
            type = "zfs_fs";
            mountpoint = ds.mountpoint;
          })
          cfg.datasets;
      };
    };
  };
}
