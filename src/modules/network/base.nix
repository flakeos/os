{ config, lib, pkgs, ... }:
{
  networking = {
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
    firewall.enable = false;
  };
  services.avahi = {
    enable = lib.mkDefault false;
    nssmdns4 = lib.mkDefault true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    iwd
    iw
    wirelesstools
    ethtool
  ];
}
