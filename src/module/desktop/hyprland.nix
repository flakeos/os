{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.desktop.hyprland;
  hyprConfigDir = ./../../config/desktop/hypr;
in
{
  options.flakeos.desktop.hyprland = {
    enable = mkOption { type = types.bool; description = "Hyprland Wayland compositor with Ubuntu-like desktop"; };
    packages = mkOption { type = types.listOf types.package; };
    extraPackages = mkOption { type = types.listOf types.package; };
  };
  config = mkIf cfg.enable {
    flakeos.desktop.hyprland = {
      packages = mkDefault (with pkgs; [
        hyprland
        waybar
        rofi-wayland
        swaync
        hyprpaper
        hyprlock
        swayidle
        wlogout
        foot
        nautilus
        networkmanagerapplet
        blueman
        polkit-gnome
        qt6ct
        libsForQt5.qt5ct
        yaru-theme
        glib
        gsettings-desktop-schemas
        gtk3
        brightnessctl
        pavucontrol
        wireplumber
      ]);
      extraPackages = mkDefault [ ];
    };
    assertions = [
      {
        assertion = !config.flakeos.desktop.kde.enable;
        message = "Hyprland and KDE cannot be enabled simultaneously";
      }
      {
        assertion = !config.flakeos.desktop.gnome.enable;
        message = "Hyprland and GNOME cannot be enabled simultaneously";
      }
    ];
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
    hardware.opengl = {
      enable = true;
      driSupport = true;
    };
    security.polkit.enable = true;
    qt = {
      enable = true;
      platformTheme = "gtk2";
      style = "gtk2";
    };
    gtk = {
      enable = true;
      theme = {
        name = "Yaru";
        package = pkgs.yaru-theme;
      };
      iconTheme = {
        name = "Yaru";
        package = pkgs.yaru-theme;
      };
      cursorTheme = {
        name = "Yaru";
        package = pkgs.yaru-theme;
      };
    };
    fonts.packages = with pkgs; [ ubuntu-font-family cantarell-fonts ];
    environment.systemPackages = cfg.packages ++ cfg.extraPackages;
    environment.etc = {
      "hypr/hyprland.conf".source = hyprConfigDir + "/hyprland.conf";
      "xdg/waybar/config.jsonc".source = hyprConfigDir + "/waybar.jsonc";
      "xdg/waybar/style.css".source = hyprConfigDir + "/waybar-style.css";
      "hypr/hyprlock.conf".source = hyprConfigDir + "/hyprlock.conf";
      "xdg/swaync/config.json".source = hyprConfigDir + "/swaync-config.json";
    };
    systemd.user.services = {
      polkit-gnome = {
        description = "PolicyKit authentication agent for GNOME";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit-gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };
      swayidle = {
        description = "Sway idle management daemon";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.hyprlock}/bin/hyprlock' timeout 900 '${pkgs.systemd}/bin/systemctl suspend'";
          Restart = "on-failure";
        };
      };
    };
  };
}
