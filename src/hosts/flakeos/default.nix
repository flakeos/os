{ config, lib, pkgs, hostname, username, ... }:
with lib;
let cfg = config.flakeos.host; in {
  options.flakeos.host = {
    userGroups = mkOption { type = types.listOf types.str; };
    shell = mkOption { type = types.package; };
    zshTheme = mkOption { type = types.str; };
    zshPlugins = mkOption { type = types.listOf types.str; };
    sudoGroup = mkOption { type = types.str; };
    sshAuthorizedKeys = mkOption { type = types.listOf types.str; };
  };
  config = {
    flakeos.host = {
      userGroups = mkDefault [ "wheel" "networkmanager" "audio" "video" ];
      shell = mkDefault pkgs.zsh;
      zshTheme = mkDefault "agnoster";
      zshPlugins = mkDefault [ "git" "sudo" "systemd" "zsh-navigation-tools" ];
      sudoGroup = mkDefault "wheel";
      sshAuthorizedKeys = mkDefault [ ];
    };
    networking.hostName = hostname;

    users = {
      users.${username} = {
        isNormalUser = true;
        extraGroups = cfg.userGroups ++ lib.optionals config.flakeos.security.ssh.enable [ "microvm" ];
        shell = cfg.shell;
        openssh.authorizedKeys.keys = cfg.sshAuthorizedKeys;
      };
      users.root.openssh.authorizedKeys.keys = [ ];
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = cfg.zshTheme;
        plugins = cfg.zshPlugins;
      };
    };

    security.sudo = {
      enable = true;
      extraRules = [{
        groups = [ cfg.sudoGroup ];
        commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
      }];
    };
  };
}
