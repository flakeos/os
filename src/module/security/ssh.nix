{ config, lib, ... }:
with lib;
let cfg = config.flakeos.security.ssh; in {
  options.flakeos.security.ssh = {
    enable = mkOption { type = types.bool; description = "SSH server hardening"; };
    port = mkOption { type = types.port; };
    permitRootLogin = mkOption { type = types.str; };
    passwordAuth = mkOption { type = types.bool; };
    pubkeyAuth = mkOption { type = types.bool; };
    maxAuthTries = mkOption { type = types.int; };
    maxSessions = mkOption { type = types.int; };
    maxStartups = mkOption { type = types.str; };
    tcpForwarding = mkOption { type = types.bool; };
    agentForwarding = mkOption { type = types.bool; };
    ciphers = mkOption { type = types.listOf types.str; };
    kexAlgorithms = mkOption { type = types.listOf types.str; };
    macs = mkOption { type = types.listOf types.str; };
    hostKeyPath = mkOption { type = types.str; };
    rsaKeyPath = mkOption { type = types.str; };
    kbdInteractiveAuth = mkOption { type = types.bool; };
    authenticationMethods = mkOption { type = types.str; };
    usePAM = mkOption { type = types.bool; };
    loginGraceTime = mkOption { type = types.int; };
    permitTunnel = mkOption { type = types.bool; };
    x11Forwarding = mkOption { type = types.bool; };
    clientAliveInterval = mkOption { type = types.int; };
    clientAliveCountMax = mkOption { type = types.int; };
    hostKeyAlgorithms = mkOption { type = types.str; };
    compression = mkOption { type = types.str; };
    rsaKeyBits = mkOption { type = types.int; };
    fail2ban = {
      enable = mkOption { type = types.bool; };
      maxretry = mkOption { type = types.int; };
      bantime = mkOption { type = types.str; };
      banaction = mkOption { type = types.str; };
    };
  };
  config = mkIf cfg.enable {
    flakeos.security.ssh = {
      port = mkDefault 22;
      permitRootLogin = mkDefault "no";
      passwordAuth = mkDefault false;
      pubkeyAuth = mkDefault true;
      maxAuthTries = mkDefault 3;
      maxSessions = mkDefault 4;
      maxStartups = mkDefault "10:30:60";
      tcpForwarding = mkDefault false;
      agentForwarding = mkDefault false;
      ciphers = mkDefault [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
      kexAlgorithms = mkDefault [ "curve25519-sha256" "diffie-hellman-group-exchange-sha256" ];
      macs = mkDefault [ "hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com" ];
      hostKeyPath = mkDefault "/persist/ssh/ssh_host_ed25519_key";
      rsaKeyPath = mkDefault "/persist/ssh/ssh_host_rsa_key";
      kbdInteractiveAuth = mkDefault false;
      authenticationMethods = mkDefault "publickey";
      usePAM = mkDefault false;
      loginGraceTime = mkDefault 30;
      permitTunnel = mkDefault false;
      x11Forwarding = mkDefault false;
      clientAliveInterval = mkDefault 300;
      clientAliveCountMax = mkDefault 0;
      hostKeyAlgorithms = mkDefault "ssh-ed25519,rsa-sha2-512";
      compression = mkDefault "no";
      rsaKeyBits = mkDefault 4096;
      fail2ban = {
        enable = mkDefault true;
        maxretry = mkDefault 3;
        bantime = mkDefault "24h";
        banaction = mkDefault "nftables-multiport";
      };
    };
    services.openssh = {
      enable = true;
      ports = [ cfg.port ];
      settings = {
        PermitRootLogin = cfg.permitRootLogin;
        PasswordAuthentication = cfg.passwordAuth;
        KbdInteractiveAuthentication = cfg.kbdInteractiveAuth;
        AuthenticationMethods = cfg.authenticationMethods;
        PubkeyAuthentication = cfg.pubkeyAuth;
        UsePAM = cfg.usePAM;
        MaxAuthTries = cfg.maxAuthTries;
        MaxSessions = cfg.maxSessions;
        MaxStartups = cfg.maxStartups;
        LoginGraceTime = cfg.loginGraceTime;
        AllowTcpForwarding = cfg.tcpForwarding;
        AllowAgentForwarding = cfg.agentForwarding;
        PermitTunnel = cfg.permitTunnel;
        X11Forwarding = cfg.x11Forwarding;
        ClientAliveInterval = cfg.clientAliveInterval;
        ClientAliveCountMax = cfg.clientAliveCountMax;
        Ciphers = cfg.ciphers;
        KexAlgorithms = cfg.kexAlgorithms;
        Macs = cfg.macs;
        HostKeyAlgorithms = cfg.hostKeyAlgorithms;
        Compression = cfg.compression;
      };
      hostKeys = [
        { path = cfg.hostKeyPath; type = "ed25519"; }
        { path = cfg.rsaKeyPath; type = "rsa"; bits = cfg.rsaKeyBits; }
      ];
    };
    services.fail2ban = mkIf cfg.fail2ban.enable {
      enable = true;
      maxretry = cfg.fail2ban.maxretry;
      bantime = cfg.fail2ban.bantime;
      banaction = cfg.fail2ban.banaction;
    };
  };
}
