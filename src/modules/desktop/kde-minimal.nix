{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.desktop.kde;
  kdeMinimal = with pkgs; [
    kdePackages.plasma-desktop
    kdePackages.plasma-workspace
    kdePackages.kwin
    kdePackages.kirigami
    kdePackages.qqc2-desktop-style
    kdePackages.plasma-integration
    kdePackages.breeze-icons
    kdePackages.breeze-gtk

    kdePackages.konsole
    kdePackages.systemsettings
    kdePackages.dolphin
    kdePackages.kate
  ];
in
{
  options.flakeos.desktop.kde = {
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
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        source-code-pro
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];
      fontconfig.defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
    xdg.portal.enable = true;
  };
}
