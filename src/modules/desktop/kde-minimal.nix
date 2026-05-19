{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.bora.desktop.kde;
  kdeMinimal = with pkgs; [
    plasma6
    kdePackages.plasma-workspace
    kdePackages.kwin
    kdePackages.kirigami
    kdePackages.qqc2-desktop-style
    kdePackages.plasma-integration
    kdePackages.breeze-icons
    kdePackages.breeze-gtk
    kdePackages.breeze-qt5
    kdePackages.konsole
    kdePackages.systemsettings
    dolphin
    kate
  ];
in {
  options.bora.desktop.kde = {
    enable = mkEnableOption "KDE Plasma 6 minimal desktop";
    enableWayland = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland session";
    };
    excludePackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs.kdePackages; [
        elisa
        gwenview
        khelpcenter
        okular
        oxygen
        krdp
        krfb
        ktorrent
        kget
        korganizer
        kaddressbook
        kmail
        akonadi
        kontact
      ];
      description = "KDE packages to exclude";
    };
  };
  config = mkIf cfg.enable {
    services = {
      displayManager.sddm = {
        enable = true;
        wayland.enable = cfg.enableWayland;
        theme = "breeze";
        autoNumlock = true;
      };
      desktopManager.plasma6 = {
        enable = true;
        enableQt5Integration = false;
      };
    };
    environment.plasma6.excludePackages = cfg.excludePackages;
    environment.systemPackages = kdeMinimal;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        source-code-pro
        (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
      ];
      fontconfig.defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-kde ];
      configPackages = [ pkgs.xdg-desktop-portal-kde ];
    };
  };
}
