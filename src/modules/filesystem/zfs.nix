{ config, lib, pkgs, ... }:
{
  services.zfs = {
    trim = {
      enable = true;
      interval = "weekly";
    };
    autoScrub = {
      enable = true;
      interval = "monthly";
    };
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
    zed = {
      enable = true;
      settings = {
        ZED_EMAIL_ADDR = "";
        ZED_NOTIFY_INTERVAL_SECS = 3600;
      };
    };
  };
  boot.zfs = {
    forceImportRoot = false;
    forceImportAll = false;
    allowHibernation = false;
    requestEncryptionCredentials = true;
  };
  services.sanoid = {
    enable = true;
    templates = {
      default = {
        hourly = 24;
        daily = 30;
        weekly = 12;
        monthly = 6;
        yearly = 2;
        autosnap = true;
        autoprune = true;
      };
      critical = {
        hourly = 48;
        daily = 90;
        weekly = 24;
        monthly = 12;
        yearly = 5;
        autosnap = true;
        autoprune = true;
      };
      ephemeral = {
        hourly = 2;
        daily = 1;
        autosnap = true;
        autoprune = true;
      };
    };
  };
  boot.kernelParams = [
    "zfs.zfs_arc_max=8589934592"
    "zfs.zfs_arc_min=1073741824"
  ];
  networking.hostId = "deadbeef";
}
