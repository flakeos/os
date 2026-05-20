{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nixpkgs-fmt
    statix
    deadnix
    nixos-anywhere
  ];
  shellHook = ''
    echo "FlakeOS Test Environment"
    echo "Run: statix check ../src"
    echo "Run: deadnix ../src"
    echo "Run: nixpkgs-fmt --check ../src"
  '';
}
