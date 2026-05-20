{ lib, pkgs, ... }:
{
  time.timeZone = lib.mkDefault "Europe/Rome";
  i18n = {
    defaultLocale = lib.mkDefault "it_IT.UTF-8";
    supportedLocales = [
      "it_IT.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "C.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_ADDRESS = lib.mkDefault "it_IT.UTF-8";
      LC_IDENTIFICATION = lib.mkDefault "it_IT.UTF-8";
      LC_MEASUREMENT = lib.mkDefault "it_IT.UTF-8";
      LC_MONETARY = lib.mkDefault "it_IT.UTF-8";
      LC_NAME = lib.mkDefault "it_IT.UTF-8";
      LC_NUMERIC = lib.mkDefault "it_IT.UTF-8";
      LC_PAPER = lib.mkDefault "it_IT.UTF-8";
      LC_TELEPHONE = lib.mkDefault "it_IT.UTF-8";
      LC_TIME = lib.mkDefault "it_IT.UTF-8";
    };
  };
  console = {
    font = lib.mkDefault "Lat2-Terminus16";
    keyMap = lib.mkDefault "it";
    packages = with pkgs; [ terminus_font ];
  };
  services = {
    dbus.enable = true;
    udisks2.enable = true;
    upower.enable = lib.mkDefault true;
    fwupd.enable = lib.mkDefault true;
  };
}
