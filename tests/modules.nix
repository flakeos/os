{ system ? builtins.currentSystem, nixpkgs ? import <nixpkgs> { inherit system; } }:

let
  lib = nixpkgs.lib;
  inherit (builtins) toString;

  assertEq = name: actual: expected:
    if actual == expected
    then { ${name} = { ok = true; }; }
    else { ${name} = { ok = false; expected = expected; actual = actual; }; };
in

# =============================================================================
  # NixOS module integration tests
  # =============================================================================
(
  let
    hardwareDB = import ../lib/hardware.nix { lib = nixpkgs.lib; };

    # Minimal NixOS config that exercises module loading via configuration.nix
    minimalConfig = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../configuration.nix
        ({ pkgs, lib, ... }: {
          system.stateVersion = "25.11";
          users.users.root.hashedPassword = "!";
          boot.loader.grub.enable = false;
          boot.loader.systemd-boot.enable = false;
          fileSystems."/" = { device = "/dev/null"; fsType = "tmpfs"; };
          nixpkgs.config.allowUnfree = true;
        })
      ];
      specialArgs = {
        inherit hardwareDB;
        hostname = "test";
        username = "testuser";
        hardwareProfile = "desktop";
        systemProfile = "minimal";
      };
    };
  in
  {
    testModuleLoading =
      let
        cfg = minimalConfig.config;
      in
      assertEq "module.loading.hostname" cfg.networking.hostName "test";

    # Verify bora modules registered their options
    testBoraOptionsExist =
      let
        cfg = minimalConfig.config;
      in
      assertEq "bora.options.exist" (cfg ? bora) true;

    # Verify enableNvidiaPrime defaults to false
    testEnableNvidiaPrimeDefault =
      let
        cfg = minimalConfig.config;
      in
      assertEq "bora.hardware.enableNvidiaPrime.default"
        (if cfg ? bora && cfg.bora ? hardware then (cfg.bora.hardware.enableNvidiaPrime or false) else false)
        false;

    # Verify bora container options registered
    testBoraContainerOptions =
      let
        cfg = minimalConfig.config;
      in
      assertEq "bora.options.containers.exist" (cfg ? bora && cfg.bora ? containers) true;
  }
) //

# =============================================================================
# Module composition tests: profile + module interaction
# =============================================================================
(
  let
    hardwareDB = import ../lib/hardware.nix { lib = nixpkgs.lib; };

    makeConfig = profile:
      let
        cfg = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ../configuration.nix
            ({ pkgs, lib, ... }: {
              system.stateVersion = "25.11";
              users.users.root.hashedPassword = "!";
              boot.loader.grub.enable = false;
              boot.loader.systemd-boot.enable = false;
              fileSystems."/" = { device = "/dev/null"; fsType = "tmpfs"; };
              nixpkgs.config.allowUnfree = true;
            })
          ];
          specialArgs = {
            inherit hardwareDB;
            hostname = "test";
            username = "testuser";
            hardwareProfile = "desktop";
            systemProfile = profile;
          };
        };
      in
      cfg.config;
  in
  {
    testProfileMinimal =
      let
        cfg = makeConfig "minimal";
      in
      {
        testProfileMinimalHostname = assertEq "profile.minimal.hostname" cfg.networking.hostName "test";
        testProfileMinimalSSH = assertEq "profile.minimal.openssh.enable" (cfg.services.openssh.enable or false) true;
      };

    testProfileServer =
      let
        cfg = makeConfig "server";
      in
      {
        testProfileServerSSH = assertEq "profile.server.openssh.enable" (cfg.services.openssh.enable or false) true;
        testProfileFirewallPorts = assertEq "profile.server.firewall.ports" (cfg.networking.firewall.allowedTCPPorts or [ ]) [ 22 80 443 ];
      };
  }
) //

  # =============================================================================
  # Spring bean config integration
  # =============================================================================
(
  let
    hardwareDB = import ../lib/hardware.nix { lib = nixpkgs.lib; };

    configWithSpring = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../configuration.nix
        ({ pkgs, lib, ... }: {
          system.stateVersion = "25.11";
          users.users.root.hashedPassword = "!";
          boot.loader.grub.enable = false;
          boot.loader.systemd-boot.enable = false;
          fileSystems."/" = { device = "/dev/null"; fsType = "tmpfs"; };
          nixpkgs.config.allowUnfree = true;
        })
        ({ pkgs, lib, ... }: {
          bora.spring.application = {
            enable = true;
            name = "testapp";
          };
          bora.spring.beans = {
            database = {
              enable = true;
              class = "Database";
              resources = { cpu = "1"; memory = "256M"; memoryMax = "512M"; pids = 256; };
            };
            webapp = {
              enable = true;
              class = "WebApp";
              deps = [ "database" ];
              resources = { cpu = "2"; memory = "512M"; memoryMax = "1G"; pids = 512; };
            };
          };
        })
      ];
      specialArgs = {
        inherit hardwareDB;
        hostname = "test-spring";
        username = "testuser";
        hardwareProfile = "desktop";
        systemProfile = "minimal";
      };
    };
  in
  {
    testSpringIntegration =
      let
        services = configWithSpring.config.systemd.services or { };
        slices = configWithSpring.config.systemd.slices or { };
        hasService = n: builtins.hasAttr n services;
        hasSlice = n: builtins.hasAttr n slices;
      in
      {
        testSpringDatabaseService = assertEq "spring.service.database" (hasService "spring-testapp-database") true;
        testSpringWebappService = assertEq "spring.service.webapp" (hasService "spring-testapp-webapp") true;
        testSpringSlice = assertEq "spring.slice" (hasSlice "system-testapp.slice") true;
      };
  }
)
