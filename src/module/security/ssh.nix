{ config, lib, ... }:
with lib;
let cfg = config.flakeos.security.ssh; in {
  options.flakeos.security.ssh = {
    enable = mkEnableOption "SSH server hardening";
    port = mkOption { type = types.port; default = 22; };
    permitRootLogin = mkOption { type = types.str; default = "no"; };
    passwordAuth = mkOption { type = types.bool; default = false; };
    pubkeyAuth = mkOption { type = types.bool; default = true; };
    maxAuthTries = mkOption { type = types.int; default = 3; };
    maxSessions = mkOption { type = types.int; default = 4; };
    maxStartups = mkOption { type = types.str; default = "10:30:60"; };
    tcpForwarding = mkOption { type = types.bool; default = false; };
    agentForwarding = mkOption { type = types.bool; default = false; };
    ciphers = mkOption { type = types.listOf types.str; default = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ]; };
    kexAlgorithms = mkOption { type = types.listOf types.str; default = [ "curve25519-sha256" "diffie-hellman-group-exchange-sha256" ]; };
    macs = mkOption { type = types.listOf types.str; default = [ "hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com" ]; };
    hostKeyPath = mkOption { type = types.str; default = "/persist/ssh/ssh_host_ed25519_key"; };
    rsaKeyPath = mkOption { type = types.str; default = "/persist/ssh/ssh_host_rsa_key"; };
    fail2ban = {
      enable = mkOption { type = types.bool; default = true; };
      maxretry = mkOption { type = types.int; default = 3; };
      bantime = mkOption { type = types.str; default = "24h"; };
    };
  };
  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ cfg.port ];
      settings = {
        PermitRootLogin = cfg.permitRootLogin;
        PasswordAuthentication = cfg.passwordAuth;
        KbdInteractiveAuthentication = false;
        AuthenticationMethods = "publickey";
        PubkeyAuthentication = cfg.pubkeyAuth;
        UsePAM = false;
        MaxAuthTries = cfg.maxAuthTries;
        MaxSessions = cfg.maxSessions;
        MaxStartups = cfg.maxStartups;
        LoginGraceTime = 30;
        AllowTcpForwarding = cfg.tcpForwarding;
        AllowAgentForwarding = cfg.agentForwarding;
        PermitTunnel = false;
        X11Forwarding = false;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 0;
        Ciphers = cfg.ciphers;
        KexAlgorithms = cfg.kexAlgorithms;
        Macs = cfg.macs;
        HostKeyAlgorithms = "ssh-ed25519,rsa-sha2-512";
        Compression = "no";
      };
      hostKeys = [
        { path = cfg.hostKeyPath; type = "ed25519"; }
        { path = cfg.rsaKeyPath; type = "rsa"; bits = 4096; }
      ];
    };
    services.fail2ban = mkIf cfg.fail2ban.enable {
      enable = true;
      maxretry = cfg.fail2ban.maxretry;
      bantime = cfg.fail2ban.bantime;
      banaction = "nftables-multiport";
    };
  };
}
