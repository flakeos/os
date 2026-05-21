{ config, lib, ... }:
with lib;
let cfg = config.flakeos.network.dns; in {
  options.flakeos.network.dns = {
    enable = mkOption { type = types.bool; description = "systemd-resolved DNS"; };
    primaryDns = mkOption { type = types.listOf types.str; };
    fallbackDns = mkOption { type = types.listOf types.str; };
    dnsOverTls = mkOption { type = types.bool; };
    dnssec = mkOption { type = types.str; };
    stubListener = mkOption { type = types.bool; };
    domains = mkOption { type = types.listOf types.str; };
  };
  config = mkIf cfg.enable {
    flakeos.network.dns = {
      primaryDns = mkDefault [ "9.9.9.9" "149.112.112.112" ];
      fallbackDns = mkDefault [ "2620:fe::fe" "2620:fe::9" ];
      dnsOverTls = mkDefault true;
      dnssec = mkDefault "true";
      stubListener = mkDefault true;
      domains = mkDefault [ "~." ];
    };
    services.resolved = {
      enable = true;
      dnssec = cfg.dnssec;
      domains = cfg.domains;
      fallbackDns = cfg.fallbackDns;
      extraConfig = ''
        DNSStubListener=${if cfg.stubListener then "yes" else "no"}
        DNSOverTLS=${if cfg.dnsOverTls then "yes" else "no"}
        DNS=${builtins.concatStringsSep " " cfg.primaryDns}
        Domains=${builtins.concatStringsSep " " cfg.domains}
      '';
    };
  };
}
