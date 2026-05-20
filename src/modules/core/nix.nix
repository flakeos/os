{ lib, pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "ca-derivations" ];
      auto-optimise-store = true;
      max-jobs = lib.mkDefault 8;
      max-substitution-jobs = 64;
      min-free = 1073741824;
      max-free = 5368709120;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://astro-microvm.cachix.org"
        "https://bora.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "astro-microvm.cachix.org-1:5VxKj9V5rE1xJgF2gQvA0Z3L8R6bH7cN4pY9sW1tXnM="
      ];
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise = {
      automatic = true;
      dates = [ "03:00" ];
    };
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/persist/etc/nixos/configuration.nix"
    ];
  };
}
