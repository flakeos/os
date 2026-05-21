{ config, lib, ... }:
with lib;
let cfg = config.flakeos.filesystem.zfs; in {
  options.flakeos.filesystem.zfs = {
    zfsPool = mkOption { type = types.str; default = "zroot"; };
    bootDevice = mkOption { type = types.str; };
    hostId = mkOption { type = types.str; };
    arcMax = mkOption { type = types.str; };
    arcMin = mkOption { type = types.str; };
    trim = {
      enable = mkOption { type = types.bool; default = true; };
      interval = mkOption { type = types.str; default = "weekly"; };
    };
    scrub = {
      enable = mkOption { type = types.bool; default = true; };
      interval = mkOption { type = types.str; default = "monthly"; };
    };
    snapshot = {
      enable = mkOption { type = types.bool; default = true; };
      flags = mkOption { type = types.str; default = "-k -p --utc"; };
    };
    sanoid = {
      enable = mkOption { type = types.bool; default = true; };
      templates = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            hourly = mkOption { type = types.int; default = 0; };
            daily = mkOption { type = types.int; default = 0; };
            weekly = mkOption { type = types.int; default = 0; };
            monthly = mkOption { type = types.int; default = 0; };
            yearly = mkOption { type = types.int; default = 0; };
            autosnap = mkOption { type = types.bool; default = true; };
            autoprune = mkOption { type = types.bool; default = true; };
          };
        });
        default = {
          default = { hourly = 24; daily = 30; weekly = 12; monthly = 6; yearly = 2; };
          critical = { hourly = 48; daily = 90; weekly = 24; monthly = 12; yearly = 5; };
          ephemeral = { hourly = 2; daily = 1; };
        };
      };
    };
    forceImportRoot = mkOption { type = types.bool; default = false; };
    forceImportAll = mkOption { type = types.bool; default = false; };
    allowHibernation = mkOption { type = types.bool; default = false; };
    requestEncryptionCredentials = mkOption { type = types.bool; default = true; };
  };
  config = {
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
