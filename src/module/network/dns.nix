{ config, lib, ... }:
with lib;
let cfg = config.flakeos.network.dns; in {
  options.flakeos.network.dns = {
    enable = mkEnableOption "systemd-resolved DNS";
    primaryDns = mkOption { type = types.listOf types.str; default = [ "9.9.9.9" "149.112.112.112" ]; };
    fallbackDns = mkOption { type = types.listOf types.str; default = [ "2620:fe::fe" "2620:fe::9" ]; };
    dnsOverTls = mkOption { type = types.bool; default = true; };
    dnssec = mkOption { type = types.str; default = "true"; };
    stubListener = mkOption { type = types.bool; default = true; };
  };
  config = mkIf cfg.enable {
    services.resolved = {
      enable = true;
      dnssec = cfg.dnssec;
      domains = [ "~." ];
      fallbackDns = cfg.fallbackDns;
      extraConfig = ''
        DNSStubListener=${if cfg.stubListener then "yes" else "no"}
        DNSOverTLS=${if cfg.dnsOverTls then "yes" else "no"}
        DNS=${builtins.concatStringsSep " " cfg.primaryDns}
        Domains=~.
      '';
    };
  };
}
