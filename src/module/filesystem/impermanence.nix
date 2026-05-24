{ config, lib, username, ... }:
with lib;
let cfg = config.flakeos.filesystem.impermanence; in {
  options.flakeos.filesystem.impermanence = {
    enable = mkOption { type = types.bool; };
    persistPath = mkOption { type = types.str; };
    zfsPool = mkOption { type = types.str; };
    hideMounts = mkOption { type = types.bool; };
    persistFsType = mkOption { type = types.str; };
    persistNeededForBoot = mkOption { type = types.bool; };
    homeFsType = mkOption { type = types.str; };
    homeNeededForBoot = mkOption { type = types.bool; };
    persistDirectories = mkOption { type = types.listOf types.str; };
    persistFiles = mkOption { type = types.listOf types.str; };
    userDirectories = mkOption { type = types.listOf types.str; };
    userFiles = mkOption { type = types.listOf types.str; };
  };
  config = mkIf (cfg.enable && username != "") {
    flakeos.filesystem.impermanence = {
      enable = mkDefault true;
      persistPath = mkDefault "/persist";
      zfsPool = mkDefault "zroot";
      hideMounts = mkDefault true;
      persistFsType = mkDefault "zfs";
      persistNeededForBoot = mkDefault true;
      homeFsType = mkDefault "zfs";
      homeNeededForBoot = mkDefault true;
      persistDirectories = mkDefault [
        "/etc/nixos"
        "/etc/NetworkManager"
        "/etc/ssh"
        "/etc/udev"
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/lib/bluetooth"
        "/var/lib/tor"
        "/var/log"
        "/var/lib/microvm"
      ];
      persistFiles = mkDefault [
        "/etc/machine-id"
        "/etc/resolv.conf"
        "/etc/adjtime"
      ];
      userDirectories = mkDefault [
        "Downloads"
        "Documents"
        "Video"
        "Music"
        "Projects"
        "Go"
        ".ssh"
        ".gnupg"
        ".local/share/keyrings"
        ".config/gtk-3.0"
        ".config/gtk-4.0"
        ".config/qt5ct"
        ".config/qt6ct"
        ".config/KDE"
        ".config/kdeglobals"
        ".config/systemd"
        ".cache/mozilla"
        ".mozilla"
      ];
      userFiles = mkDefault [
        ".config/user-dirs.dirs"
      ];
    };
    environment.persistence."${cfg.persistPath}" = {
      hideMounts = cfg.hideMounts;
      directories = cfg.persistDirectories;
      files = cfg.persistFiles;
      users.${username} = {
        directories = cfg.userDirectories;
        files = cfg.userFiles;
      };
    };
    fileSystems."${cfg.persistPath}" = {
      device = "${cfg.zfsPool}/root/persist";
      fsType = cfg.persistFsType;
      neededForBoot = cfg.persistNeededForBoot;
    };
    fileSystems."/home" = {
      device = "${cfg.zfsPool}/root/home";
      fsType = cfg.homeFsType;
      neededForBoot = cfg.homeNeededForBoot;
    };
  };
}
