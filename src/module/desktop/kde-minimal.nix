{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.desktop.kde;
in
{
  options.flakeos.desktop.kde = {
    enable = mkEnableOption "KDE Plasma 6 minimal desktop";
    enableWayland = mkOption { type = types.bool; default = true; };
    enableSddm = mkOption { type = types.bool; default = true; };
    sddmTheme = mkOption { type = types.str; default = "breeze"; };
    sddmAutoNumlock = mkOption { type = types.bool; default = true; };
    enablePlasma6 = mkOption { type = types.bool; default = true; };
    enableQt5Integration = mkOption { type = types.bool; default = false; };
    enableGraphics = mkOption { type = types.bool; default = true; };
    enableGraphics32Bit = mkOption { type = types.bool; default = true; };
    enableXdgPortal = mkOption { type = types.bool; default = true; };
    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
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
    };
    fontPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        source-code-pro
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];
    };
    defaultSerifFont = mkOption { type = types.listOf types.str; default = [ "Noto Serif" ]; };
    defaultSansSerifFont = mkOption { type = types.listOf types.str; default = [ "Noto Sans" ]; };
    defaultMonospaceFont = mkOption { type = types.listOf types.str; default = [ "JetBrainsMono Nerd Font" ]; };
    defaultEmojiFont = mkOption { type = types.listOf types.str; default = [ "Noto Color Emoji" ]; };
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
    };
  };
  config = mkIf cfg.enable {
    services = {
      displayManager.sddm = mkIf cfg.enableSddm {
        enable = true;
        wayland.enable = cfg.enableWayland;
        theme = cfg.sddmTheme;
        autoNumlock = cfg.sddmAutoNumlock;
      };
      desktopManager.plasma6 = mkIf cfg.enablePlasma6 {
        enable = true;
        enableQt5Integration = cfg.enableQt5Integration;
      };
    };
    environment.plasma6.excludePackages = cfg.excludePackages;
    environment.systemPackages = cfg.packages;
    hardware.graphics = {
      enable = cfg.enableGraphics;
      enable32Bit = cfg.enableGraphics32Bit;
    };
    fonts = {
      enableDefaultPackages = true;
      packages = cfg.fontPackages;
      fontconfig.defaultFonts = {
        serif = cfg.defaultSerifFont;
        sansSerif = cfg.defaultSansSerifFont;
        monospace = cfg.defaultMonospaceFont;
        emoji = cfg.defaultEmojiFont;
      };
    };
    xdg.portal.enable = cfg.enableXdgPortal;
  };
}
