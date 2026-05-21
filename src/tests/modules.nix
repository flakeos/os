{ system ? builtins.currentSystem, nixpkgs ? import <nixpkgs> { inherit system; } }:

let
  assertEq = name: actual: expected:
    if actual == expected
    then { ${name} = { ok = true; }; }
    else { ${name} = { ok = false; inherit expected actual; }; };
in

(
  let
    hardwareDB = import ../../lib/hardware.nix { inherit (nixpkgs) lib; };

    minimalConfig = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../../configuration.nix
        (_: {
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

    testBoraOptionsExist =
      let
        cfg = minimalConfig.config;
      in
      assertEq "flakeos.options.exist" (cfg ? flakeos) true;

    testEnableNvidiaPrimeDefault =
      let
        cfg = minimalConfig.config;
      in
      assertEq "flakeos.hardware.enableNvidiaPrime.default"
        (if cfg ? flakeos && cfg.flakeos ? hardware then (cfg.flakeos.hardware.enableNvidiaPrime or false) else false)
        false;

    testBoraContainerOptions =
      let
        cfg = minimalConfig.config;
      in
      assertEq "flakeos.options.containers.exist" (cfg ? flakeos && cfg.flakeos ? containers) true;
  }
) //

(
  let
    hardwareDB = import ../../lib/hardware.nix { inherit (nixpkgs) lib; };

    makeConfig = profile:
      let
        cfg = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ../../configuration.nix
            (_: {
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

(
  let
    hardwareDB = import ../../lib/hardware.nix { inherit (nixpkgs) lib; };

    configWithSpring = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ../../configuration.nix
        (_: {
          system.stateVersion = "25.11";
          users.users.root.hashedPassword = "!";
          boot.loader.grub.enable = false;
          boot.loader.systemd-boot.enable = false;
          fileSystems."/" = { device = "/dev/null"; fsType = "tmpfs"; };
          nixpkgs.config.allowUnfree = true;
        })
        (_: {
          flakeos.spring.application = {
            enable = true;
            name = "testapp";
          };
          flakeos.spring.beans = {
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
