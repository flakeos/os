{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.desktop.kde;
in
{
  options.flakeos.desktop.kde = {
    enable = mkOption { type = types.bool; description = "KDE Plasma 6 minimal desktop"; };
    enableWayland = mkOption { type = types.bool; };
    enableSddm = mkOption { type = types.bool; };
    sddmTheme = mkOption { type = types.str; };
    sddmAutoNumlock = mkOption { type = types.bool; };
    enablePlasma6 = mkOption { type = types.bool; };
    enableQt5Integration = mkOption { type = types.bool; };
    enableGraphics = mkOption { type = types.bool; };
    enableGraphics32Bit = mkOption { type = types.bool; };
    enableXdgPortal = mkOption { type = types.bool; };
    packages = mkOption { type = types.listOf types.package; };
    fontPackages = mkOption { type = types.listOf types.package; };
    defaultSerifFont = mkOption { type = types.listOf types.str; };
    defaultSansSerifFont = mkOption { type = types.listOf types.str; };
    defaultMonospaceFont = mkOption { type = types.listOf types.str; };
    defaultEmojiFont = mkOption { type = types.listOf types.str; };
    excludePackages = mkOption { type = types.listOf types.package; };
  };
  config = mkIf cfg.enable {
    flakeos.desktop.kde = {
      enableWayland = mkDefault true;
      enableSddm = mkDefault true;
      sddmTheme = mkDefault "breeze";
      sddmAutoNumlock = mkDefault true;
      enablePlasma6 = mkDefault true;
      enableQt5Integration = mkDefault false;
      enableGraphics = mkDefault true;
      enableGraphics32Bit = mkDefault true;
      enableXdgPortal = mkDefault true;
      packages = mkDefault (with pkgs; [
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
      ]);
      fontPackages = mkDefault (with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        source-code-pro
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ]);
      defaultSerifFont = mkDefault [ "Noto Serif" ];
      defaultSansSerifFont = mkDefault [ "Noto Sans" ];
      defaultMonospaceFont = mkDefault [ "JetBrainsMono Nerd Font" ];
      defaultEmojiFont = mkDefault [ "Noto Color Emoji" ];
      excludePackages = mkDefault (with pkgs.kdePackages; [
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
      ]);
    };
    assertions = [
      {
        assertion = !config.flakeos.desktop.hyprland.enable;
        message = "KDE Plasma 6 cannot be enabled alongside Hyprland";
      }
      {
        assertion = !config.flakeos.desktop.gnome.enable;
        message = "KDE Plasma 6 cannot be enabled alongside GNOME";
      }
    ];
    security.polkit.enable = true;
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
