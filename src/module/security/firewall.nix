{ config, lib, ... }:
with lib;
let cfg = config.flakeos.security.firewall; in {
  options.flakeos.security.firewall = {
    enable = mkOption { type = types.bool; description = "nftables firewall"; };
    lanRanges = mkOption { type = types.listOf types.str; };
    sshPort = mkOption { type = types.port; };
    wanInterface = mkOption { type = types.str; };
    microvmInterface = mkOption { type = types.str; };
    icmpRateLimit = mkOption { type = types.str; };
    mdnsPort = mkOption { type = types.port; };
    dhcpPorts = mkOption { type = types.listOf types.port; };
    inputLogPrefix = mkOption { type = types.str; };
    forwardLogPrefix = mkOption { type = types.str; };
  };
  config = mkIf cfg.enable {
    flakeos.security.firewall = {
      lanRanges = mkDefault [ "10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" ];
      sshPort = mkDefault 22;
      wanInterface = mkDefault "eth0";
      microvmInterface = mkDefault "microvm";
      icmpRateLimit = mkDefault "10/second";
      mdnsPort = mkDefault 5353;
      dhcpPorts = mkDefault [ 67 68 ];
      inputLogPrefix = mkDefault "NF:DROP-INPUT: ";
      forwardLogPrefix = mkDefault "NF:DROP-FORWARD: ";
    };
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
            udp dport ${toString cfg.mdnsPort} ip saddr {
              ${builtins.concatStringsSep ", " cfg.lanRanges}
            } accept;
            udp dport ${concatStringsSep ", " (map toString cfg.dhcpPorts)} accept;
            log prefix "${cfg.inputLogPrefix}" drop;
          }
          chain forward {
            type filter hook forward priority 0; policy drop;
            ct state { established, related } accept;
            iifname "${cfg.microvmInterface}" accept;
            log prefix "${cfg.forwardLogPrefix}" drop;
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
