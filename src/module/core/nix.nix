{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.core.nix; in {
  options.flakeos.core.nix = {
    maxJobs = mkOption { type = types.int; default = 8; };
    maxSubstitutionJobs = mkOption { type = types.int; default = 64; };
    minFree = mkOption { type = types.int; default = 1073741824; };
    maxFree = mkOption { type = types.int; default = 5368709120; };
    substituters = mkOption {
      type = types.listOf types.str;
      default = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://astro-microvm.cachix.org"
        "https://flakeos.cachix.org"
      ];
    };
    trustedPublicKeys = mkOption {
      type = types.listOf types.str;
      default = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "astro-microvm.cachix.org-1:5VxKj9V5rE1xJgF2gQvA0Z3L8R6bH7cN4pY9sW1tXnM="
      ];
    };
    trustedUsers = mkOption { type = types.listOf types.str; default = [ "root" "@wheel" ]; };
    gcInterval = mkOption { type = types.str; default = "weekly"; };
    gcOptions = mkOption { type = types.str; default = "--delete-older-than 14d"; };
    optimizeInterval = mkOption { type = types.listOf types.str; default = [ "03:00" ]; };
    nixPathEntries = mkOption {
      type = types.listOf types.str;
      default = [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
        "nixos-config=/persist/etc/nixos/configuration.nix"
      ];
    };
  };
  config = {
    nix = {
      package = pkgs.nixVersions.stable;
      settings = {
        experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "ca-derivations" ];
        auto-optimise-store = true;
        max-jobs = mkDefault cfg.maxJobs;
        max-substitution-jobs = cfg.maxSubstitutionJobs;
        min-free = cfg.minFree;
        max-free = cfg.maxFree;
        substituters = cfg.substituters;
        trusted-public-keys = cfg.trustedPublicKeys;
        trusted-users = cfg.trustedUsers;
      };
      gc = {
        automatic = true;
        dates = cfg.gcInterval;
        options = cfg.gcOptions;
      };
      optimise = {
        automatic = true;
        dates = cfg.optimizeInterval;
      };
      nixPath = cfg.nixPathEntries;
    };
  };
}
