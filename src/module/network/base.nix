{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.network.base; in {
  options.flakeos.network.base = {
    enable = mkOption { type = types.bool; description = "base network configuration"; };
    enableNetworkManager = mkOption { type = types.bool; };
    useDHCP = mkOption { type = types.bool; };
    enableFirewall = mkOption { type = types.bool; };
    avahi = {
      enable = mkOption { type = types.bool; };
      nssmdns4 = mkOption { type = types.bool; };
      publishAddresses = mkOption { type = types.bool; };
      publishWorkstation = mkOption { type = types.bool; };
      publishUserServices = mkOption { type = types.bool; };
    };
    packages = mkOption { type = types.listOf types.package; };
  };
  config = mkIf cfg.enable {
    flakeos.network.base = {
      enableNetworkManager = mkDefault true;
      useDHCP = mkDefault true;
      enableFirewall = mkDefault false;
      avahi = {
        enable = mkDefault false;
        nssmdns4 = mkDefault true;
        publishAddresses = mkDefault true;
        publishWorkstation = mkDefault true;
        publishUserServices = mkDefault true;
      };
      packages = mkDefault (with pkgs; [
        networkmanagerapplet
        iwd
        iw
        wirelesstools
        ethtool
      ]);
    };
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
