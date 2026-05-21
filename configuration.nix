{ config, lib, pkgs, hostname, hardwareProfile, systemProfile, ... }:
let
  inherit (builtins) readDir pathExists attrNames;
  inherit (lib) optional mkDefault;

  modulesDir = ./src/module;
  moduleCats = attrNames (readDir modulesDir);
  profilesDir = ./src/profiles;

  scanDefaultNix = dir:
    let
      entries = attrNames (readDir dir);
      hasDefault = builtins.elem "default.nix" entries;
    in
    [ (dir + "/default.nix") ];

  autoImportedModules = builtins.foldl'
    (acc: cat:
      let catDir = modulesDir + "/${cat}";
      in if pathExists (catDir + "/default.nix") then acc ++ [ (catDir + "/default.nix") ] else acc
    ) [ ]
    moduleCats;

  profilePath = profilesDir + "/${systemProfile}.nix";
in
{
  imports = autoImportedModules
    ++ optional (pathExists profilePath) profilePath;

  nixpkgs.config.allowUnfree = mkDefault true;
  system.stateVersion = mkDefault "25.11";
}
