{ config, lib, pkgs, hostname, username, ... }:
with lib;
let cfg = config.flakeos.host; in {
  options.flakeos.host = {
    userGroups = mkOption { type = types.listOf types.str; default = [ "wheel" "networkmanager" "audio" "video" ]; };
    shell = mkOption { type = types.package; default = pkgs.zsh; };
    zshTheme = mkOption { type = types.str; default = "agnoster"; };
    zshPlugins = mkOption { type = types.listOf types.str; default = [ "git" "sudo" "systemd" "zsh-navigation-tools" ]; };
    sudoGroup = mkOption { type = types.str; default = "wheel"; };
    sshAuthorizedKeys = mkOption { type = types.listOf types.str; default = [ ]; };
  };
  config = {
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
