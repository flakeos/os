{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.core.locale; in {
  options.flakeos.core.locale = {
    timeZone = mkOption { type = types.str; default = "Europe/Rome"; };
    defaultLocale = mkOption { type = types.str; default = "it_IT.UTF-8"; };
    extraLocales = mkOption { type = types.listOf types.str; default = [ "en_US.UTF-8/UTF-8" "C.UTF-8/UTF-8" ]; };
    consoleFont = mkOption { type = types.str; default = "Lat2-Terminus16"; };
    consoleKeyMap = mkOption { type = types.str; default = "it"; };
    consoleFontPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ terminus_font ];
    };
    enableDbus = mkOption { type = types.bool; default = true; };
    enableUdisks2 = mkOption { type = types.bool; default = true; };
    enableUpower = mkOption { type = types.bool; default = true; };
    enableFwupd = mkOption { type = types.bool; default = true; };
  };
  config = {
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
