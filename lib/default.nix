{ nixpkgs }:
let
  inherit (nixpkgs) lib;
  inherit (builtins) readDir pathExists;
  inherit (lib) attrNames filter hasPrefix;
in
{
  hardware = import ./hardware.nix { inherit lib; };
  atomic = {
    preRebuildSnapshot = pool: dataset: ''
      zfs snapshot ${pool}/${dataset}@pre-rebuild-$(date +%Y%m%d-%H%M%S)
    '';
    backupGeneration = ''
      nix-env --list-generations -p /nix/var/nix/profiles/system
    '';
  };
  scanModules = dir:
    let
      isDir = path: (pathExists (dir + "/${path}")) && (hasPrefix "." path);
      entries = attrNames (readDir dir);
      dirs = filter isDir entries;
    in
    map (name: dir + "/${name}") dirs;
}
