{ config, lib, pkgs, ... }:
with lib;
let cfg = config.flakeos.core.nix; in {
  options.flakeos.core.nix = {
    enable = mkOption { type = types.bool; };
    maxJobs = mkOption { type = types.int; };
    maxSubstitutionJobs = mkOption { type = types.int; };
    minFree = mkOption { type = types.int; };
    maxFree = mkOption { type = types.int; };
    package = mkOption { type = types.package; };
    experimentalFeatures = mkOption { type = types.listOf types.str; };
    autoOptimiseStore = mkOption { type = types.bool; };
    substituters = mkOption { type = types.listOf types.str; };
    trustedPublicKeys = mkOption { type = types.listOf types.str; };
    trustedUsers = mkOption { type = types.listOf types.str; };
    gc = {
      automatic = mkOption { type = types.bool; };
      interval = mkOption { type = types.str; };
      options = mkOption { type = types.str; };
    };
    optimise = {
      automatic = mkOption { type = types.bool; };
      dates = mkOption { type = types.listOf types.str; };
    };
    nixPathEntries = mkOption { type = types.listOf types.str; };
  };
  config = mkIf cfg.enable {
    flakeos.core.nix = {
      enable = mkDefault true;
      maxJobs = mkDefault 8;
      maxSubstitutionJobs = mkDefault 64;
      minFree = mkDefault 1073741824;
      maxFree = mkDefault 5368709120;
      package = mkDefault pkgs.nixVersions.stable;
      experimentalFeatures = mkDefault [ "nix-command" "flakes" "auto-allocate-uids" "ca-derivations" ];
      autoOptimiseStore = mkDefault true;
      substituters = mkDefault [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://astro-microvm.cachix.org"
        "https://flakeos.cachix.org"
      ];
      trustedPublicKeys = mkDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "astro-microvm.cachix.org-1:5VxKj9V5rE1xJgF2gQvA0Z3L8R6bH7cN4pY9sW1tXnM="
      ];
      trustedUsers = mkDefault [ "root" "@wheel" ];
      gc = {
        automatic = mkDefault true;
        interval = mkDefault "weekly";
        options = mkDefault "--delete-older-than 14d";
      };
      optimise = {
        automatic = mkDefault true;
        dates = mkDefault [ "03:00" ];
      };
      nixPathEntries = mkDefault [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
        "nixos-config=/persist/etc/nixos/configuration.nix"
      ];
    };
    nix = {
      package = cfg.package;
      settings = {
        experimental-features = cfg.experimentalFeatures;
        auto-optimise-store = cfg.autoOptimiseStore;
        max-jobs = mkDefault cfg.maxJobs;
        max-substitution-jobs = cfg.maxSubstitutionJobs;
        min-free = cfg.minFree;
        max-free = cfg.maxFree;
        substituters = cfg.substituters;
        trusted-public-keys = cfg.trustedPublicKeys;
        trusted-users = cfg.trustedUsers;
      };
      gc = {
        automatic = cfg.gc.automatic;
        dates = cfg.gc.interval;
        options = cfg.gc.options;
      };
      optimise = {
        automatic = cfg.optimise.automatic;
        dates = cfg.optimise.dates;
      };
      nixPath = cfg.nixPathEntries;
    };
  };
}
