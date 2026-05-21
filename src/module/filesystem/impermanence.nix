{ config, lib, username, ... }:
with lib;
let cfg = config.flakeos.filesystem.impermanence; in {
  options.flakeos.filesystem.impermanence = {
    persistPath = mkOption { type = types.str; default = "/persist"; };
    zfsPool = mkOption { type = types.str; default = "zroot"; };
    persistDirectories = mkOption { type = types.listOf types.str; default = [
      "/etc/nixos" "/etc/NetworkManager" "/etc/ssh" "/etc/udev"
      "/var/lib/nixos" "/var/lib/systemd" "/var/lib/bluetooth"
      "/var/lib/tor" "/var/log" "/var/lib/microvm"
    ]; };
    persistFiles = mkOption { type = types.listOf types.str; default = [
      "/etc/machine-id" "/etc/resolv.conf" "/etc/adjtime"
    ]; };
    userDirectories = mkOption { type = types.listOf types.str; default = [
      "Downloads" "Documents" "Video" "Musica" "Projects" "Go"
      ".ssh" ".gnupg" ".local/share/keyrings"
      ".config/gtk-3.0" ".config/gtk-4.0" ".config/qt5ct" ".config/qt6ct"
      ".config/KDE" ".config/kdeglobals" ".config/systemd"
      ".cache/mozilla" ".mozilla"
    ]; };
    userFiles = mkOption { type = types.listOf types.str; default = [
      ".config/user-dirs.dirs"
    ]; };
  };
  config = mkIf (username != "") {
    environment.persistence."${cfg.persistPath}" = {
      hideMounts = true;
      directories = cfg.persistDirectories;
      files = cfg.persistFiles;
      users.${username} = {
        directories = cfg.userDirectories;
        files = cfg.userFiles;
      };
    };
    fileSystems."${cfg.persistPath}" = {
      device = "${cfg.zfsPool}/root/persist";
      fsType = "zfs";
      neededForBoot = true;
    };
    fileSystems."/home" = {
      device = "${cfg.zfsPool}/root/home";
      fsType = "zfs";
      neededForBoot = true;
    };
  };
}
