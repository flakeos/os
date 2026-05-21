{ config, lib, ... }:
with lib;
let cfg = config.flakeos.security.firewall; in {
  options.flakeos.security.firewall = {
    enable = mkEnableOption "nftables firewall";
    lanRanges = mkOption { type = types.listOf types.str; default = [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ]; };
    sshPort = mkOption { type = types.port; default = 22; };
    wanInterface = mkOption { type = types.str; default = "eth0"; };
    microvmInterface = mkOption { type = types.str; default = "microvm"; };
    icmpRateLimit = mkOption { type = types.str; default = "10/second"; };
  };
  config = mkIf cfg.enable {
    networking.nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;
            ct state invalid drop;
            ct state { established, related } accept;
            iifname lo accept;
            icmp type {
              echo-request, destination-unreachable,
              time-exceeded, parameter-problem
            } limit rate ${cfg.icmpRateLimit} accept;
            meta l4proto ipv6-icmp icmpv6 type {
              echo-request, destination-unreachable,
              time-exceeded, parameter-problem,
              nd-router-advert, nd-neighbor-solicit,
              nd-neighbor-advert, nd-router-solicit
            } limit rate ${cfg.icmpRateLimit} accept;
            tcp dport ${toString cfg.sshPort} ip saddr {
              ${builtins.concatStringsSep ", " cfg.lanRanges}
            } accept;
            udp dport 5353 ip saddr {
              ${builtins.concatStringsSep ", " cfg.lanRanges}
            } accept;
            udp dport { 67, 68 } accept;
            log prefix "NF:DROP-INPUT: " drop;
          }
          chain forward {
            type filter hook forward priority 0; policy drop;
            ct state { established, related } accept;
            iifname "${cfg.microvmInterface}" accept;
            log prefix "NF:DROP-FORWARD: " drop;
          }
          chain output {
            type filter hook output priority 0; policy accept;
          }
        }
        table inet nat {
          chain postrouting {
            type nat hook postrouting priority 100;
            oifname "${cfg.wanInterface}" masquerade;
          }
        }
      '';
    };
  };
}
