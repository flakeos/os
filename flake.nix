{
  description = "Bora NixOS — Modulare · Atomico · Universale · Strict-Hard — ALPHA v0.1.0";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    microvm = {
      url = "github:astro/microvm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware
            , nixos-generators, impermanence, microvm, disko
            , sops-nix, home-manager, ...
            }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      boraLib = import ./lib { inherit nixpkgs; };
      inherit (builtins) readDir attrNames;
      inherit (nixpkgs.lib) optional;

      hostsDir = ./src/hosts;
      availableHosts = attrNames (readDir hostsDir);

      mkHost = hostname: hostConfig:
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system or "x86_64-linux";
          specialArgs = {
            inherit boraLib self;
            hostname = hostname;
            username = hostConfig.username or "user";
            hardwareProfile = hostConfig.hardware or "desktop";
            systemProfile = hostConfig.profile or "minimal";
          };
          modules = [
            impermanence.nixosModules.impermanence
            microvm.nixosModules.host
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            ./configuration.nix
            (hostsDir + "/${hostname}")
          ] ++ optional (hostConfig ? extraModules) hostConfig.extraModules;
        };

      hosts = builtins.foldl' (acc: hostname:
        let
          hostConfig =
            if builtins.pathExists (hostsDir + "/${hostname}/meta.nix")
            then import (hostsDir + "/${hostname}/meta.nix")
            else { };
        in acc // {
          ${hostname} = mkHost hostname hostConfig;
        }
      ) { } availableHosts;

    in {
      nixosConfigurations = hosts;

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in {
          iso-minimal = nixos-generators.nixosGenerate {
            inherit system;
            modules = [
              impermanence.nixosModules.impermanence
              disko.nixosModules.disko
              ./configuration.nix
              ({ pkgs, ... }: {
                isoImage.isoBaseName = "bora";
                isoImage.compress = true;
                boot.supportedFilesystems = [ "zfs" "vfat" "xfs" ];
                nixpkgs.config.allowUnfree = true;
                system.stateVersion = "24.11";
              })
            ];
            format = "iso";
          };

          iso-graphical = nixos-generators.nixosGenerate {
            inherit system;
            modules = [
              impermanence.nixosModules.impermanence
              disko.nixosModules.disko
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-kde.nix"
              ./configuration.nix
              ({ pkgs, ... }: {
                isoImage.isoBaseName = "bora-desktop";
                isoImage.compress = true;
                boot.supportedFilesystems = [ "zfs" "vfat" "xfs" ];
                nixpkgs.config.allowUnfree = true;
                services.xserver.enable = true;
                system.stateVersion = "24.11";
              })
            ];
            format = "iso";
          };
        });

      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixos-generators nixos-anywhere
              nixpkgs-fmt statix deadnix comma
            ];
          };
        });

      formatter = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.nixpkgs-fmt);
    };
}
