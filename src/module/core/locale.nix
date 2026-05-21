{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.core.locale; in {
  options.flakeos.core.locale = {
    timeZone = mkOption { type = types.str; };
    defaultLocale = mkOption { type = types.str; };
    extraLocales = mkOption { type = types.listOf types.str; };
    consoleFont = mkOption { type = types.str; };
    consoleKeyMap = mkOption { type = types.str; };
    consoleFontPackages = mkOption { type = types.listOf types.package; };
    enableDbus = mkOption { type = types.bool; };
    enableUdisks2 = mkOption { type = types.bool; };
    enableUpower = mkOption { type = types.bool; };
    enableFwupd = mkOption { type = types.bool; };
  };
  config = {
    flakeos.core.locale = {
      timeZone = mkDefault "Europe/Rome";
      defaultLocale = mkDefault "it_IT.UTF-8";
      extraLocales = mkDefault [ "en_US.UTF-8/UTF-8" "C.UTF-8/UTF-8" ];
      consoleFont = mkDefault "Lat2-Terminus16";
      consoleKeyMap = mkDefault "it";
      consoleFontPackages = mkDefault (with pkgs; [ terminus_font ]);
      enableDbus = mkDefault true;
      enableUdisks2 = mkDefault true;
      enableUpower = mkDefault true;
      enableFwupd = mkDefault true;
    };
    time.timeZone = mkDefault cfg.timeZone;
    i18n = {
      defaultLocale = mkDefault cfg.defaultLocale;
      supportedLocales = [ "${cfg.defaultLocale}/UTF-8" ] ++ cfg.extraLocales;
      extraLocaleSettings = {
        LC_ADDRESS = mkDefault cfg.defaultLocale;
        LC_IDENTIFICATION = mkDefault cfg.defaultLocale;
        LC_MEASUREMENT = mkDefault cfg.defaultLocale;
        LC_MONETARY = mkDefault cfg.defaultLocale;
        LC_NAME = mkDefault cfg.defaultLocale;
        LC_NUMERIC = mkDefault cfg.defaultLocale;
        LC_PAPER = mkDefault cfg.defaultLocale;
        LC_TELEPHONE = mkDefault cfg.defaultLocale;
        LC_TIME = mkDefault cfg.defaultLocale;
      };
    };
    console = {
      font = mkDefault cfg.consoleFont;
      keyMap = mkDefault cfg.consoleKeyMap;
      packages = cfg.consoleFontPackages;
    };
    services.dbus.enable = cfg.enableDbus;
    services.udisks2.enable = cfg.enableUdisks2;
    services.upower.enable = mkDefault cfg.enableUpower;
    services.fwupd.enable = mkDefault cfg.enableFwupd;
  };
}
