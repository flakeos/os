{ nixpkgs }:
let
  inherit (nixpkgs) lib;
  inherit (builtins) readDir pathExists readFile replaceStrings;
  inherit (lib) attrNames filter hasPrefix;
  snapshotTmpl = readFile ../src/scripts/system/pre-rebuild-snapshot.sh;
  listGenScript = readFile ../src/scripts/system/list-generations.sh;
in
{
  hardware = import ./hardware.nix { inherit lib; };
  atomic = {
    preRebuildSnapshot = pool: dataset:
      replaceStrings [ "@POOL@" "@DATASET@" ] [ pool dataset ] snapshotTmpl;
    backupGeneration = listGenScript;
  };
  scanModules = dir:
    let
      isDir = path: (pathExists (dir + "/${path}")) && (hasPrefix "." path);
      entries = attrNames (readDir dir);
      dirs = filter isDir entries;
    in
    map (name: dir + "/${name}") dirs;
}
