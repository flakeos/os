_:
{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      PubkeyAuthentication = true;
      UsePAM = false;
      MaxAuthTries = 3;
      MaxSessions = 4;
      MaxStartups = "10:30:60";
      LoginGraceTime = 30;
      AllowTcpForwarding = false;
      AllowAgentForwarding = false;
      PermitTunnel = false;
      X11Forwarding = false;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 0;
      Ciphers = [ "chacha20-poly1305@openssh.com" "aes256-gcm@openssh.com" ];
      KexAlgorithms = [ "curve25519-sha256" "diffie-hellman-group-exchange-sha256" ];
      Macs = [ "hmac-sha2-512-etm@openssh.com" "hmac-sha2-256-etm@openssh.com" ];
      HostKeyAlgorithms = "ssh-ed25519,rsa-sha2-512";
      Compression = "no";
    };
    hostKeys = [
      {
        path = "/persist/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "24h";
    banaction = "nftables-multiport";
  };
}
