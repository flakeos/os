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
  setupCgroup = pkgs.writeShellScriptBin "setup-cgroup"
    (builtins.readFile ./../../scripts/containers/setup-cgroup.sh);
  createPoolZfs = pkgs.writeShellScriptBin "create-pool-zfs"
    (builtins.readFile ./../../scripts/containers/create-pool-zfs.sh);
in
{
  options.flakeos.containers.instancePool = {
    enable = mkEnableOption "MicroVM instance pool orchestrator";
    zfsPool = mkOption { type = types.str; default = "zroot"; };
    poolDir = mkOption { type = types.str; default = "/var/lib/instance-pool"; };
    cgroupDir = mkOption { type = types.str; default = "/sys/fs/cgroup/flakeos/pool"; };
    cgroupIoDevice = mkOption { type = types.str; default = "8:0"; };
    maxInstances = mkOption { type = types.int; default = 899; };
    basePort = mkOption { type = types.port; default = 8443; };
    memPerInstance = mkOption { type = types.str; default = "256M"; };
    cpuPerInstance = mkOption { type = types.str; default = "0.5"; };
    pidsPerInstance = mkOption { type = types.str; default = "512"; };
    storagePerInstance = mkOption { type = types.str; default = "2G"; };
    appPackage = mkOption { type = types.nullOr types.package; default = null; };
    appCommand = mkOption { type = types.nullOr types.str; default = null; };
    healthcheckCmd = mkOption { type = types.nullOr types.str; default = null; };
    caddyDomain = mkOption { type = types.str; default = "pool.flakeos.local"; };
    serviceType = mkOption { type = types.str; default = "notify"; };
    serviceRestart = mkOption { type = types.str; default = "always"; };
    serviceRestartSec = mkOption { type = types.int; default = 5; };
    serviceLimitNoFile = mkOption { type = types.int; default = 1048576; };
    serviceLimitNProc = mkOption { type = types.int; default = 1048576; };
  };
  config = mkIf cfg.enable {
    systemd.services = {
      create-pool-zfs = {
        description = "Create ZFS dataset for instance pool";
        before = [ "flakeos-pool.service" ];
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [ zfs ];
        script = ''
          ${createPoolZfs}/bin/create-pool-zfs \
            "${cfg.zfsPool}" \
            "${cfg.poolDir}" \
            "${toString (cfg.maxInstances * 2)}G"
        '';
      };
      flakeos-cgroup-pool = {
        description = "Instance pool cgroup v2 hierarchy";
        before = [ "flakeos-pool.service" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          ${setupCgroup}/bin/setup-cgroup \
            "${cfg.cgroupDir}" \
            "${cfg.memPerInstance}" \
            "${cfg.cpuPerInstance}" \
            "${cfg.pidsPerInstance}" \
            "${cfg.storagePerInstance}" \
            "${cfg.cgroupIoDevice}"
        '';
      };
      flakeos-pool = {
        description = "MicroVM Instance Pool";
        after = [ "network.target" "microvm-host.service" "create-pool-zfs.service" ];
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
        };
        script = ''
          ${builtins.readFile (scriptsDir + "/pool-manager.sh")}
        '';
      };
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
