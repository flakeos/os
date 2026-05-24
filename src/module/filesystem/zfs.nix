{ config, lib, ... }:
with lib;
let cfg = config.flakeos.filesystem.zfs; in {
  options.flakeos.filesystem.zfs = {
    zfsPool = mkOption { type = types.str; };
    bootDevice = mkOption { type = types.str; };
    hostId = mkOption { type = types.str; };
    arcMax = mkOption { type = types.str; };
    arcMin = mkOption { type = types.str; };
    trim = {
      enable = mkOption { type = types.bool; };
      interval = mkOption { type = types.str; };
    };
    scrub = {
      enable = mkOption { type = types.bool; };
      interval = mkOption { type = types.str; };
    };
    snapshot = {
      enable = mkOption { type = types.bool; };
      flags = mkOption { type = types.str; };
    };
    sanoid = {
      enable = mkOption { type = types.bool; };
      templates = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            hourly = mkOption { type = types.int; };
            daily = mkOption { type = types.int; };
            weekly = mkOption { type = types.int; };
            monthly = mkOption { type = types.int; };
            yearly = mkOption { type = types.int; };
            autosnap = mkOption { type = types.bool; };
            autoprune = mkOption { type = types.bool; };
          };
        });
      };
    };
    forceImportRoot = mkOption { type = types.bool; };
    forceImportAll = mkOption { type = types.bool; };
    allowHibernation = mkOption { type = types.bool; };
    requestEncryptionCredentials = mkOption { type = types.bool; };
  };
  config = {
    flakeos.filesystem.zfs = {
      zfsPool = mkDefault "zroot";
      trim = {
        enable = mkDefault true;
        interval = mkDefault "weekly";
      };
      scrub = {
        enable = mkDefault true;
        interval = mkDefault "monthly";
      };
      snapshot = {
        enable = mkDefault true;
        flags = mkDefault "-k -p --utc";
      };
      sanoid = {
        enable = mkDefault true;
        templates = mkDefault {
          default = { hourly = 24; daily = 30; weekly = 12; monthly = 6; yearly = 2; };
          critical = { hourly = 48; daily = 90; weekly = 24; monthly = 12; yearly = 5; };
          ephemeral = { hourly = 2; daily = 1; };
        };
      };
      forceImportRoot = mkDefault false;
      forceImportAll = mkDefault false;
      allowHibernation = mkDefault false;
      requestEncryptionCredentials = mkDefault true;
      arcMax = mkDefault "0";
      arcMin = mkDefault "0";
    };
    services.zfs.trim = {
      enable = cfg.trim.enable;
      interval = cfg.trim.interval;
    };
    services.zfs.autoScrub = {
      enable = cfg.scrub.enable;
      interval = cfg.scrub.interval;
    };
    services.zfs.autoSnapshot = {
      enable = cfg.snapshot.enable;
      flags = cfg.snapshot.flags;
    };
    boot.zfs = {
      forceImportRoot = cfg.forceImportRoot;
      forceImportAll = cfg.forceImportAll;
      allowHibernation = cfg.allowHibernation;
      requestEncryptionCredentials = cfg.requestEncryptionCredentials;
    };
    services.sanoid = {
      enable = cfg.sanoid.enable;
      templates = cfg.sanoid.templates;
    };
    boot.kernelParams = [
      "zfs.zfs_arc_max=${cfg.arcMax}"
      "zfs.zfs_arc_min=${cfg.arcMin}"
    ];
    networking.hostId = cfg.hostId;
  };
}
