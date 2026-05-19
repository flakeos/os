{ config, lib, pkgs, ... }:
{
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
    ];
    extraConfig = ''
      DNSStubListener=yes
      DNSOverTLS=yes
      DNS=9.9.9.9 149.112.112.112
      Domains=~.
    '';
  };
}
