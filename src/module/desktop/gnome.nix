{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.desktop.gnome;
in
{
  options.flakeos.desktop.gnome = {
    enable = mkEnableOption "GNOME desktop with Yaru Ubuntu theme";
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.flakeos.desktop.hyprland.enable;
        message = "GNOME cannot be enabled alongside Hyprland";
      }
      {
        assertion = !config.flakeos.desktop.kde.enable;
        message = "GNOME cannot be enabled alongside KDE Plasma 6";
      }
    ];
    services.xserver.desktopManager.gnome.enable = true;
    environment.systemPackages = with pkgs; [
      yaru-theme
      gnome-tweaks
    ] ++ cfg.extraPackages;
    environment.gnome.excludePackages = with pkgs.gnome; [
      cheese
      epiphany
      geary
      gnome-music
      gnome-tour
      totem
      tali
      iagno
      hitori
      atomix
    ];
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
    qt = {
      enable = true;
      platformTheme = "gtk2";
      style = "gtk2";
    };
    fonts.packages = with pkgs; [
      cantarell-fonts
      ubuntu-font-family
    ];
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];
    };
    security.polkit.enable = true;
    hardware.opengl = {
      enable = true;
      driSupport = true;
    };
  };
}
