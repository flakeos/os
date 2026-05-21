{ lib, pkgs, ... }:
let
  inherit (builtins) toString mapAttrs attrNames;
  inherit (lib)
    types mkOption
    mapAttrsToList filterAttrs
    optional any attrValues;
in
rec {
  springType = types.submodule (_: {
    options = {
      application = mkOption {
        type = types.submodule (_: {
          options = {
            enable = mkOption { type = types.bool; };
            name = mkOption { type = types.str; };
            version = mkOption { type = types.str; };
            resourceGovernor = mkOption {
              type = types.enum [ "strict" "normal" "relaxed" ];
            };
            globalLimits = mkOption {
              type = types.submodule {
                options = {
                  memory = mkOption { type = types.str; };
                  cpu = mkOption { type = types.str; };
                  pids = mkOption { type = types.int; };
                  io = mkOption { type = types.str; };
                };
              };
            };
            circuitBreaker = mkOption {
              type = types.submodule {
                options = {
                  enable = mkOption { type = types.bool; };
                  failureThreshold = mkOption { type = types.int; };
                  successThreshold = mkOption { type = types.int; };
                  timeoutMs = mkOption { type = types.int; };
                  halfOpenMax = mkOption { type = types.int; };
                };
              };
            };
          };
        });
      };
      beans = mkOption {
        type = types.attrsOf (types.submodule (_: {
          options = {
            enable = mkOption { type = types.bool; };
            class = mkOption { type = types.str; };
            deps = mkOption { type = types.listOf types.str; };
            resources = mkOption {
              type = types.submodule {
                options = {
                  cpu = mkOption { type = types.str; };
                  memory = mkOption { type = types.str; };
                  memoryMax = mkOption { type = types.str; };
                  pids = mkOption { type = types.int; };
                  ioRbps = mkOption { type = types.str; };
                  ioRops = mkOption { type = types.int; };
                  ioWbps = mkOption { type = types.str; };
                  ioWops = mkOption { type = types.int; };
                  numa = mkOption {
                    type = types.nullOr (types.listOf types.int);
                  };
                };
              };
            };
            healthcheck = mkOption { type = types.nullOr types.str; };
            livenessProbe = mkOption { type = types.nullOr types.str; };
            startupProbe = mkOption { type = types.nullOr types.str; };
            dependsOn = mkOption { type = types.listOf types.str; };
            after = mkOption { type = types.listOf types.str; };
            wants = mkOption { type = types.listOf types.str; };
            restartPolicy = mkOption {
              type = types.enum [ "always" "on-failure" "no" ];
            };
            restartSec = mkOption { type = types.int; };
            config = mkOption { type = types.attrsOf types.anything; };
            environment = mkOption { type = types.attrsOf types.str; };
            serviceType = mkOption {
              type = types.enum [ "oneshot" "simple" "forking" "dbus" "notify" "idle" ];
            };
            timeoutStartSec = mkOption { type = types.int; };
            timeoutStopSec = mkOption { type = types.int; };
          };
        }));
      };
      profiles = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            enable = mkOption { type = types.bool; };
            extends = mkOption { type = types.listOf types.str; };
            beans = mkOption { type = types.attrsOf types.anything; };
            config = mkOption { type = types.attrsOf types.anything; };
          };
        });
      };
      autowire = mkOption {
        type = types.submodule {
          options = {
            enable = mkOption { type = types.bool; };
            strict = mkOption { type = types.bool; };
            circularCheck = mkOption { type = types.bool; };
          };
        };
      };
    };
  });

  configType = types.attrsOf types.anything;

  beanGraph = beans:
    let
      names = attrNames beans;
      edges = map
        (n: {
          name = n;
          deps = beans.${n}.deps or [ ];
          dependsOn = beans.${n}.dependsOn or [ ];
          allDeps = (beans.${n}.deps or [ ]) ++ (beans.${n}.dependsOn or [ ]);
        })
        names;
    in
    edges;

  tsort = items:
    let
      names = map (n: n.name) items;
      depsOf = name: builtins.head (map (i: i.allDeps) (builtins.filter (i: i.name == name) items));
      sorted = lib.sort (a: b: any (dep: dep == b) (depsOf a)) names;
    in
    map (n: builtins.head (builtins.filter (i: i.name == n) items)) sorted;

  detectCircular = beans:
    let
      graph = beanGraph beans;
      names = map (n: n.name) graph;
      depsOf = name: builtins.head (map (i: i.allDeps) (builtins.filter (i: i.name == name) graph));
      visit = current: visited: stack:
        if builtins.elem current stack then true
        else if builtins.elem current visited then false
        else builtins.foldl' (acc: dep: acc || visit dep (visited ++ [ current ]) (stack ++ [ current ])) false (depsOf current);
    in
    builtins.filter (name: visit name [ ] [ ]) names;

  resolveBeanConfig = beans:
    let
      graph = beanGraph beans;
      sortedNames = map (n: n.name) (tsort graph);
    in
    lib.listToAttrs (map
      (name: {
        inherit name;
        value = beans.${name};
      })
      sortedNames);

  scriptsDir = ../src/scripts/spring;
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
    in
    {
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
      beans = filterAttrs (_: v: v.enable) springConfig.beans;
      resolved = resolveBeanConfig beans;
      sortedBeans = attrValues resolved;
      serviceDefs = builtins.foldl'
        (acc: bean:
          let
            name = builtins.elemAt (builtins.filter (n: beans.${n} == bean) (attrNames beans)) 0;
          in
          acc // mkSystemdService appName name bean
        )
        { }
        sortedBeans;
    in
    {
      assertions = optional springConfig.autowire.circularCheck
        (
          let cycles = detectCircular beans; in {
            assertion = cycles == [ ];
            message = "Spring: circular dependency detected in beans: ${toString cycles}";
          }
        );
      systemd = {
        slices = mkSystemdSlice appName app;
        services = serviceDefs;
        extraConfig = ''
          DefaultMemoryAccounting=yes
          DefaultCPUAccounting=yes
          DefaultIOAccounting=yes
          DefaultTasksAccounting=yes
        '';
      };
      environment.etc."spring/${appName}/beans.json".text =
        builtins.toJSON (mapAttrs
          (_: v: {
            inherit (v) class deps resources;
            healthcheck = v.healthcheck or null;
          })
          beans);
      environment.systemPackages = [
        (wrapBin "spring-${appName}-status" "spring-status.sh")
        (wrapBin "spring-${appName}-resources" "spring-resources.sh")
        (wrapBin "spring-${appName}-restart" "spring-restart-bean.sh")
      ];
    };
}
