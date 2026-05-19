{ lib, pkgs, config ? null, ... }:
let
  inherit (builtins) toString mapAttrs;
  inherit (lib)
    types mkOption mkIf mkEnableOption mkDefault
    mapAttrsToList filterAttrs
    optional optionals optionalString concatStringsSep
    any all attrValues elem;
in rec {
  springType = types.submodule ({ name, ... }: {
    options = {
      application = mkOption {
        type = types.submodule ({ ... }: {
          options = {
            enable = mkEnableOption "Spring application context";
            name = mkOption { type = types.str; };
            version = mkOption { type = types.str; default = "1.0.0"; };
            resourceGovernor = mkOption {
              type = types.enum [ "strict" "normal" "relaxed" ];
              default = "strict";
            };
            globalLimits = mkOption {
              type = types.submodule {
                options = {
                  memory = mkOption { type = types.str; default = "0" ; };
                  cpu = mkOption { type = types.str; default = "0" ; };
                  pids = mkOption { type = types.int; default = 0 ; };
                  io = mkOption { type = types.str; default = "0" ; };
                };
              };
              default = { };
            };
            circuitBreaker = mkOption {
              type = types.submodule {
                options = {
                  enable = mkEnableOption "Circuit breaker";
                  failureThreshold = mkOption { type = types.int; default = 5 ; };
                  successThreshold = mkOption { type = types.int; default = 2 ; };
                  timeoutMs = mkOption { type = types.int; default = 30000 ; };
                  halfOpenMax = mkOption { type = types.int; default = 3 ; };
                };
              };
              default = { };
            };
          };
        });
        default = { };
      };
      beans = mkOption {
        type = types.attrsOf (types.submodule ({ ... }: {
          options = {
            enable = mkEnableOption "Spring bean";
            class = mkOption { type = types.str; };
            deps = mkOption { type = types.listOf types.str; default = [ ]; };
            resources = mkOption {
              type = types.submodule {
                options = {
                  cpu = mkOption { type = types.str; default = "1" ; };
                  memory = mkOption { type = types.str; default = "256M" ; };
                  memoryMax = mkOption { type = types.str; default = "512M" ; };
                  pids = mkOption { type = types.int; default = 256 ; };
                  ioRbps = mkOption { type = types.str; default = "100M" ; };
                  ioRops = mkOption { type = types.int; default = 1000 ; };
                  ioWbps = mkOption { type = types.str; default = "100M" ; };
                  ioWops = mkOption { type = types.int; default = 1000 ; };
                  numa = mkOption {
                    type = types.nullOr (types.listOf types.int);
                    default = null;
                  };
                };
              };
              default = { };
            };
            healthcheck = mkOption { type = types.nullOr types.str; default = null; };
            livenessProbe = mkOption { type = types.nullOr types.str; default = null; };
            startupProbe = mkOption { type = types.nullOr types.str; default = null; };
            dependsOn = mkOption { type = types.listOf types.str; default = [ ]; };
            after = mkOption { type = types.listOf types.str; default = [ ]; };
            wants = mkOption { type = types.listOf types.str; default = [ ]; };
            restartPolicy = mkOption {
              type = types.enum [ "always" "on-failure" "no" ];
              default = "always";
            };
            restartSec = mkOption { type = types.int; default = 5; };
            config = mkOption { type = types.attrsOf types.anything; default = { }; };
            environment = mkOption { type = types.attrsOf types.str; default = { }; };
            serviceType = mkOption {
              type = types.enum [ "oneshot" "simple" "forking" "dbus" "notify" "idle" ];
              default = "simple";
            };
            timeoutStartSec = mkOption { type = types.int; default = 30; };
            timeoutStopSec = mkOption { type = types.int; default = 10; };
          };
        }));
        default = { };
      };
      profiles = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            enable = mkEnableOption "Spring profile";
            extends = mkOption { type = types.listOf types.str; default = [ ]; };
            beans = mkOption { type = types.attrsOf types.anything; default = { }; };
            config = mkOption { type = types.attrsOf types.anything; default = { }; };
          };
        });
        default = { };
      };
      autowire = mkOption {
        type = types.submodule {
          options = {
            enable = mkEnableOption "Autowiring";
            strict = mkOption { type = types.bool; default = true; };
            circularCheck = mkOption { type = types.bool; default = true; };
          };
        };
        default = { };
      };
    };
  });

  configType = types.attrsOf types.anything;

  beanGraph = beans:
    let
      names = attrNames beans;
      edges = map (n: {
        name = n;
        deps = beans.${n}.deps or [ ];
        dependsOn = beans.${n}.dependsOn or [ ];
        allDeps = (beans.${n}.deps or [ ]) ++ (beans.${n}.dependsOn or [ ]);
      }) names;
    in edges;

  tsort = items:
    let
      sorted = lib.toposort (a: b:
        let
          aDependsOnB = any (dep: dep == b.name) a.allDeps;
          bDependsOnA = any (dep: dep == a.name) b.allDeps;
        in
          if aDependsOnB then lib.TO_AFTER
          else if bDependsOnA then lib.TO_BEFORE
          else lib.TO_UNORDERED
      ) items;
    in sorted.result or [ ];

  detectCircular = beans:
    let
      result = lib.toposort (a: b:
        let
          aDependsOnB = any (dep: dep == b.name) a.allDeps;
          bDependsOnA = any (dep: dep == a.name) b.allDeps;
        in
          if aDependsOnB then lib.TO_AFTER
          else if bDependsOnA then lib.TO_BEFORE
          else lib.TO_UNORDERED
      ) (beanGraph beans);
    in result.cyclic or [ ];

  resolveBeanConfig = beans:
    let
      graph = beanGraph beans;
      sortedNames = map (n: n.name) (tsort graph);
    in lib.listToAttrs (map (name: {
      inherit name;
      value = beans.${name};
    }) sortedNames);

  scriptsDir = ../scripts/spring;
  cgroupInit = builtins.readFile (scriptsDir + "/cgroup-init.sh");
  circuitBreaker = builtins.readFile (scriptsDir + "/circuit-breaker.sh");
  healthcheck = builtins.readFile (scriptsDir + "/healthcheck.sh");
  beanWrapper = builtins.readFile (scriptsDir + "/bean-wrapper.sh");

  wrapBin = name: file: pkgs.writeShellScriptBin name (builtins.readFile (scriptsDir + "/${file}"));

  mkSystemdService = appName: beanName: bean:
    let
      res = bean.resources;
      deps = bean.deps ++ bean.dependsOn;
      depServices = map (d: "spring-${appName}-${d}.service") deps;
      afterServices = depServices ++ bean.after;
      wantServices = depServices ++ bean.wants;
    in {
      "spring-${appName}-${beanName}" = {
        description = "Spring Bean: ${beanName} (${bean.class})";
        after = afterServices;
        wants = wantServices;
        wantedBy = [ "multi-user.target" ];
        requires = depServices;
        serviceConfig = {
          Type = bean.serviceType;
          Restart = bean.restartPolicy;
          RestartSec = toString bean.restartSec;
          TimeoutStartSec = toString bean.timeoutStartSec;
          TimeoutStopSec = toString bean.timeoutStopSec;
          Slice = "${appName}.slice";
          MemoryMax = res.memoryMax;
          MemoryHigh = res.memory;
          CPUQuota = "${res.cpu}0%";
          TasksMax = res.pids;
          IOReadBandwidthMax = [ "${res.ioRbps}" ];
          IOWriteBandwidthMax = [ "${res.ioWbps}" ];
          IOReadIOPSMax = [ "${toString res.ioRops}" ];
          IOWriteIOPSMax = [ "${toString res.ioWops}" ];
          Environment = mapAttrsToList (n: v: "${n}=${v}") bean.environment;
          OOMPolicy = "kill";
        };
        unitConfig = {
          StartLimitIntervalSec = "60";
          StartLimitBurst = toString (bean.resources.pids / 10);
        };
        script = ''
          ${cgroupInit}
          ${circuitBreaker}
          ${healthcheck}
          ${beanWrapper}
        '';
      };
    };

  mkSystemdSlice = appName: appCfg:
    let gl = appCfg.globalLimits;
    in {
      "system-${appName}.slice" = {
        description = "Spring Application: ${appCfg.name}";
        before = [ "multi-user.target" ];
        serviceConfig = {
          MemoryMax = gl.memory;
          CPUAccounting = true;
          MemoryAccounting = true;
          IOAccounting = true;
          TasksAccounting = true;
          DefaultMemoryLow = 0;
          DefaultStartLimitIntervalSec = 60;
          DefaultStartLimitBurst = 5;
        };
        sliceConfig = {
          MemoryMax = gl.memory;
          CPUQuota = gl.cpu;
          TasksMax = toString gl.pids;
          IOAccounting = true;
        };
      };
    };

  mkNixosConfig = springConfig:
    let
      app = springConfig.application;
      appName = app.name;
      beans = filterAttrs (n: v: v.enable) springConfig.beans;
      resolved = resolveBeanConfig beans;
      sortedBeans = attrValues resolved;
      serviceDefs = builtins.foldl' (acc: bean:
        let
          name = builtins.elemAt (builtins.filter (n: beans.${n} == bean) (attrNames beans)) 0;
        in acc // mkSystemdService appName name bean
      ) { } sortedBeans;
    in {
      assertions = optional (springConfig.autowire.circularCheck)
        (let cycles = detectCircular beans; in {
          assertion = cycles == [ ];
          message = "Spring: circular dependency detected in beans: ${toString cycles}";
        });
      systemd.slices = mkSystemdSlice appName app;
      systemd.services = serviceDefs;
      systemd.extraConfig = ''
        DefaultMemoryAccounting=yes
        DefaultCPUAccounting=yes
        DefaultIOAccounting=yes
        DefaultTasksAccounting=yes
      '';
      environment.etc."spring/${appName}/beans.json".text =
        builtins.toJSON (mapAttrs (n: v: {
          inherit (v) class deps resources;
          healthcheck = v.healthcheck or null;
        }) beans);
      environment.systemPackages = [
        (wrapBin "spring-${appName}-status" "spring-status.sh")
        (wrapBin "spring-${appName}-resources" "spring-resources.sh")
        (wrapBin "spring-${appName}-restart" "spring-restart-bean.sh")
      ];
    };
}
