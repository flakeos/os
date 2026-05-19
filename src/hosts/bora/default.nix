{ config, lib, pkgs, hostname, username, hardwareProfile, systemProfile, ... }:

{
  networking.hostName = hostname;

  users = {
    users.${username} = {
      isNormalUser = true;
      description = "Utente principale";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "libvirtd" "microvm" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ ];
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
      theme = "agnoster";
      plugins = [ "git" "sudo" "systemd" "zsh-navigation-tools" ];
    };
  };

  security.sudo = {
    enable = true;
    extraRules = [{
      groups = [ "wheel" ];
      commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }];
    }];
  };
}
