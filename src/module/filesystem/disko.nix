{ config, lib, ... }:
with lib;
let cfg = config.flakeos.filesystem.disko; in {
  options.flakeos.filesystem.disko = {
    enable = mkOption { type = types.bool; };
    disk = mkOption { type = types.str; };
    zfsPool = mkOption { type = types.str; };
    bootSize = mkOption { type = types.str; };
    bootPartitionType = mkOption { type = types.str; };
    bootFormat = mkOption { type = types.str; };
    bootMountpoint = mkOption { type = types.str; };
    zfsSize = mkOption { type = types.str; };
    datasets = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          mountpoint = mkOption { type = types.str; };
        };
      });
    };
  };
  config = mkIf cfg.enable {
    flakeos.filesystem.disko = {
      zfsPool = mkDefault "zroot";
      bootSize = mkDefault "1G";
      bootPartitionType = mkDefault "EF00";
      bootFormat = mkDefault "vfat";
      bootMountpoint = mkDefault "/boot";
      zfsSize = mkDefault "100%";
      datasets = mkDefault {
        "root" = { mountpoint = "/"; };
        "root/nix" = { mountpoint = "/nix"; };
        "root/home" = { mountpoint = "/home"; };
        "root/persist" = { mountpoint = "/persist"; };
        "root/var" = { mountpoint = "/var"; };
        "root/tmp" = { mountpoint = "/tmp"; };
      };
    };
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
