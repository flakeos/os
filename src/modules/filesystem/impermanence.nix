{ username, ... }:

{
  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
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

    files = [
      "/etc/machine-id"
      "/etc/resolv.conf"
      "/etc/adjtime"
    ];

    users.${username} = {
      directories = [
        "Downloads"
        "Documents"
        "Immagini"
        "Video"
        "Musica"
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
      files = [
        ".config/user-dirs.dirs"
      ];
    };
  };
  fileSystems."/persist" = {
    device = "zroot/root/persist";
    fsType = "zfs";
    neededForBoot = true;
  };
  fileSystems."/home" = {
    device = "zroot/root/home";
    fsType = "zfs";
    neededForBoot = true;
  };
}
