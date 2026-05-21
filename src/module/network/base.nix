{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.network.base; in {
  options.flakeos.network.base = {
    enable = mkEnableOption "base network configuration";
    enableNetworkManager = mkOption { type = types.bool; default = true; };
    useDHCP = mkOption { type = types.bool; default = true; };
    enableFirewall = mkOption { type = types.bool; default = false; };
    avahi = {
      enable = mkOption { type = types.bool; default = false; };
      nssmdns4 = mkOption { type = types.bool; default = true; };
      publishAddresses = mkOption { type = types.bool; default = true; };
      publishWorkstation = mkOption { type = types.bool; default = true; };
      publishUserServices = mkOption { type = types.bool; default = true; };
    };
    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        networkmanagerapplet
        iwd
        iw
        wirelesstools
        ethtool
      ];
    };
  };
  config = mkIf cfg.enable {
    networking = {
      networkmanager.enable = cfg.enableNetworkManager;
      useDHCP = mkDefault cfg.useDHCP;
      firewall.enable = cfg.enableFirewall;
    };
    services.avahi = {
      enable = mkDefault cfg.avahi.enable;
      nssmdns4 = mkDefault cfg.avahi.nssmdns4;
      publish = {
        enable = cfg.avahi.enable;
        addresses = cfg.avahi.publishAddresses;
        workstation = cfg.avahi.publishWorkstation;
        userServices = cfg.avahi.publishUserServices;
      };
    };
    environment.systemPackages = cfg.packages;
  };
}
