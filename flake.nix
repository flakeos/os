{
  description = "FlakeOS NixOS — Modulare · Atomico · Universale · Strict-Hard — ALPHA v0.1.0";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , nixos-generators
    , impermanence
    , microvm
    , disko
    , sops-nix
    , home-manager
    , ...
    }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      inherit (builtins) readDir attrNames;
      inherit (nixpkgs.lib) optional;

      hostsDir = ./src/hosts;
      availableHosts = attrNames (readDir hostsDir);

      hardwareDB = import ./lib/hardware.nix { lib = nixpkgs.lib; };

      mkHost = hostname: hostConfig:
        nixpkgs.lib.nixosSystem {
          system = hostConfig.system or "x86_64-linux";
          specialArgs = {
            inherit hardwareDB self;
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

      hosts = builtins.foldl'
        (acc: hostname:
          let
            hostConfig =
              if builtins.pathExists (hostsDir + "/${hostname}/meta.nix")
              then import (hostsDir + "/${hostname}/meta.nix")
              else { };
          in
          acc // {
            ${hostname} = mkHost hostname hostConfig;
          }
        )
        { }
        availableHosts;

    in
    {
      nixosConfigurations = hosts;

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in
        {
          iso-minimal = nixos-generators.nixosGenerate {
            inherit system;
            specialArgs = {
              inherit hardwareDB;
              hostname = "flakeos-iso";
              username = "flakeos";
              hardwareProfile = "desktop";
              systemProfile = "minimal";
            };
            modules = [
              impermanence.nixosModules.impermanence
              microvm.nixosModules.host
              disko.nixosModules.disko
              ./configuration.nix
              ({ pkgs, lib, ... }: {
                image.baseName = lib.mkDefault "flakeos";
                boot.supportedFilesystems = [ "zfs" "vfat" "xfs" ];
                boot.kernelPackages = pkgs.linuxPackages_6_6;
                nixpkgs.config.allowUnfree = true;
                system.stateVersion = "25.11";
                users.users.flakeos = { isNormalUser = true; };
              })
            ];
            format = "iso";
          };

          iso-desktop = nixos-generators.nixosGenerate {
            inherit system;
            specialArgs = {
              inherit hardwareDB;
              hostname = "flakeos-iso";
              username = "flakeos";
              hardwareProfile = "desktop";
              systemProfile = "workstation";
            };
            modules = [
              impermanence.nixosModules.impermanence
              microvm.nixosModules.host
              disko.nixosModules.disko
              ./configuration.nix
              ({ pkgs, lib, ... }: {
                image.baseName = lib.mkDefault "flakeos-desktop";
                boot.supportedFilesystems = [ "zfs" "vfat" "xfs" ];
                boot.kernelPackages = pkgs.linuxPackages_6_6;
                nixpkgs.config.allowUnfree = true;
                system.stateVersion = "25.11";
                users.users.flakeos = { isNormalUser = true; };
              })
            ];
            format = "iso";
          };

          iso-laptop = nixos-generators.nixosGenerate {
            inherit system;
            specialArgs = {
              inherit hardwareDB;
              hostname = "flakeos-iso";
              username = "flakeos";
              hardwareProfile = "laptop";
              systemProfile = "minimal";
            };
            modules = [
              impermanence.nixosModules.impermanence
              microvm.nixosModules.host
              disko.nixosModules.disko
              ./configuration.nix
              ({ pkgs, lib, ... }: {
                image.baseName = lib.mkDefault "flakeos-laptop";
                boot.supportedFilesystems = [ "zfs" "vfat" "xfs" ];
                boot.kernelPackages = pkgs.linuxPackages_6_6;
                nixpkgs.config.allowUnfree = true;
                system.stateVersion = "25.11";
                users.users.flakeos = { isNormalUser = true; };
              })
            ];
            format = "iso";
          };

          iso-server = nixos-generators.nixosGenerate {
            inherit system;
            specialArgs = {
              inherit hardwareDB;
              hostname = "flakeos-iso";
              username = "flakeos";
              hardwareProfile = "server";
              systemProfile = "server";
            };
            modules = [
              impermanence.nixosModules.impermanence
              microvm.nixosModules.host
              disko.nixosModules.disko
              ./configuration.nix
              ({ pkgs, lib, ... }: {
                image.baseName = lib.mkDefault "flakeos-server";
                boot.supportedFilesystems = [ "zfs" "vfat" "xfs" ];
                boot.kernelPackages = pkgs.linuxPackages_6_6;
                nixpkgs.config.allowUnfree = true;
                system.stateVersion = "25.11";
                users.users.flakeos = { isNormalUser = true; };
              })
            ];
            format = "iso";
          };
        });

      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in {
          default = pkgs.mkShell {
            name = "flakeos-dev-shell";
            buildInputs = with pkgs; [
              nixpkgs-fmt
              statix
              deadnix
            ];
          };
        });

      formatter = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.nixpkgs-fmt);
    };
}
