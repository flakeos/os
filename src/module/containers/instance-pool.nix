{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.containers.instancePool;
  scriptsDir = ./../../scripts/pool;
  poolManager = pkgs.writeShellScriptBin "pool-manager"
    (builtins.readFile (scriptsDir + "/pool-manager.sh"));
  spawnScript = pkgs.writeShellScriptBin "pool-spawn"
    (builtins.readFile (scriptsDir + "/spawn.sh"));
  listScript = pkgs.writeShellScriptBin "pool-list"
    (builtins.readFile (scriptsDir + "/list.sh"));
  statsScript = pkgs.writeShellScriptBin "pool-stats"
    (builtins.readFile (scriptsDir + "/stats.sh"));
  cpuQuota = toString (builtins.floor (builtins.fromJSON cfg.cpuPerInstance * 100)) + "%";
in
{
  options.flakeos.containers.instancePool = {
    enable = mkOption { type = types.bool; description = "MicroVM instance pool orchestrator"; };
    zfsPool = mkOption { type = types.str; };
    poolDir = mkOption { type = types.str; };
    cgroupDir = mkOption { type = types.str; };
    cgroupIoDevice = mkOption { type = types.str; };
    maxInstances = mkOption { type = types.int; };
    basePort = mkOption { type = types.port; };
    memPerInstance = mkOption { type = types.str; };
    cpuPerInstance = mkOption { type = types.str; };
    pidsPerInstance = mkOption { type = types.str; };
    storagePerInstance = mkOption { type = types.str; };
    appPackage = mkOption { type = types.nullOr types.package; };
    appCommand = mkOption { type = types.nullOr types.str; };
    healthcheckCmd = mkOption { type = types.nullOr types.str; };
    caddyDomain = mkOption { type = types.str; };
    serviceType = mkOption { type = types.str; };
    serviceRestart = mkOption { type = types.str; };
    serviceRestartSec = mkOption { type = types.int; };
    serviceLimitNoFile = mkOption { type = types.int; };
    serviceLimitNProc = mkOption { type = types.int; };
  };
  config = mkIf cfg.enable {
    flakeos.containers.instancePool = {
      zfsPool = mkDefault "zroot";
      poolDir = mkDefault "/var/lib/instance-pool";
      cgroupDir = mkDefault "/sys/fs/cgroup/flakeos/pool";
      cgroupIoDevice = mkDefault "8:0";
      maxInstances = mkDefault 899;
      basePort = mkDefault 8443;
      memPerInstance = mkDefault "256M";
      cpuPerInstance = mkDefault "0.5";
      pidsPerInstance = mkDefault "512";
      storagePerInstance = mkDefault "2G";
      appPackage = mkDefault null;
      appCommand = mkDefault null;
      healthcheckCmd = mkDefault null;
      caddyDomain = mkDefault "pool.flakeos.local";
      serviceType = mkDefault "notify";
      serviceRestart = mkDefault "always";
      serviceRestartSec = mkDefault 5;
      serviceLimitNoFile = mkDefault 1048576;
      serviceLimitNProc = mkDefault 1048576;
    };
    boot.zfs.datasets."${cfg.zfsPool}/instance-pool" = {
      mountpoint = cfg.poolDir;
      options = {
        atime = "off";
        compression = "zstd-3";
        quota = "${toString (cfg.maxInstances * 2)}G";
      };
    };
    systemd.services.flakeos-pool = {
      description = "MicroVM Instance Pool";
      after = [ "network.target" "microvm-host.service" "zfs.target" ];
      wants = [ "microvm-host.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ microvm coreutils bash curl ];
      environment = {
        POOL_DIR = cfg.poolDir;
        BASE_PORT = toString cfg.basePort;
        MAX_INSTANCES = toString cfg.maxInstances;
        MEM_LIMIT = cfg.memPerInstance;
        CPU_LIMIT = cfg.cpuPerInstance;
        APP_COMMAND = cfg.appCommand or "";
        HEALTHCHECK_CMD = cfg.healthcheckCmd or "";
        CG_DIR = cfg.cgroupDir;
      };
      serviceConfig = {
        Type = cfg.serviceType;
        Restart = cfg.serviceRestart;
        RestartSec = cfg.serviceRestartSec;
        StateDirectory = "instance-pool";
        NotifyAccess = "all";
        LimitNOFILE = cfg.serviceLimitNoFile;
        LimitNPROC = cfg.serviceLimitNProc;
        Delegate = "yes";
        MemoryMax = cfg.memPerInstance;
        MemoryHigh = cfg.memPerInstance;
        CPUQuota = cpuQuota;
        TasksMax = cfg.pidsPerInstance;
      };
      script = ''
        ${builtins.readFile (scriptsDir + "/pool-manager.sh")}
      '';
    };
    services.caddy = {
      enable = true;
      globalConfig = ''
        servers {
          trusted_proxies static private_ranges
             }
      '';
      virtualHosts."*.${cfg.caddyDomain}" = {
        extraConfig = ''
          @ws {
            header Connection *Upgrade*
            header Upgrade websocket
          }
          reverse_proxy @ws localhost:{path.port}
          reverse_proxy localhost:{path.port}
        '';
      };
    };
    networking.firewall.allowedTCPPortRanges = [
      { from = cfg.basePort; to = cfg.basePort + cfg.maxInstances; }
    ];
    environment.systemPackages = [
      poolManager
      spawnScript
      listScript
      statsScript
    ];
  };
}
