table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    ct state invalid drop;
    ct state { established, related } accept;

    iifname lo accept;

    icmp type {
      echo-request, destination-unreachable,
      time-exceeded, parameter-problem
    } limit rate 10/second accept;

    ip6 icmpv6 type {
      echo-request, destination-unreachable,
      time-exceeded, parameter-problem,
      nd-router-advert, nd-neighbor-solicit,
      nd-neighbor-advert, nd-router-solicit
    } limit rate 10/second accept;

    tcp dport 22 ip saddr {
      10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
    } accept;

    udp dport 5353 ip saddr {
      10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
    } accept;

    udp dport { 67, 68 } accept;

    log prefix "NF:DROP-INPUT: " drop;
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
    ct state { established, related } accept;

    iifname "microvm" oifname "microvm" accept;
    iifname "microvm" oifname "eth0" masquerade accept;

    log prefix "NF:DROP-FORWARD: " drop;
  }

  chain output {
    type filter hook output priority 0; policy accept;
  }
}

table inet nat {
  chain postrouting {
    type nat hook postrouting priority 100;
    oifname "eth0" masquerade;
  }
}
