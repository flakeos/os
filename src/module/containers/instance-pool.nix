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
in
{
  options.flakeos.containers.instancePool = {
    enable = mkEnableOption "MicroVM instance pool orchestrator";
    maxInstances = mkOption {
      type = types.int;
      default = 899;
    };
    basePort = mkOption {
      type = types.port;
      default = 8443;
    };
    memPerInstance = mkOption {
      type = types.str;
      default = "256M";
    };
    cpuPerInstance = mkOption {
      type = types.str;
      default = "0.5";
    };
    storagePerInstance = mkOption {
      type = types.str;
      default = "2G";
    };
    appPackage = mkOption {
      type = types.nullOr types.package;
      default = null;
    };
    appCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    healthcheckCmd = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };
  config = mkIf cfg.enable {
    systemd.services = {
      create-pool-zfs = {
        description = "Create ZFS dataset for instance pool";
        before = [ "flakeos-pool.service" ];
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [ zfs ];
        script = ''
          zfs create -o mountpoint=/var/lib/instance-pool \
            -o atime=off -o compression=zstd-3 \
            -o quota=${toString (cfg.maxInstances * 2)}G \
            zroot/root/instance-pool 2>/dev/null || true
        '';
      };
      flakeos-cgroup-pool = {
        description = "Instance pool cgroup v2 hierarchy";
        before = [ "flakeos-pool.service" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          CG="/sys/fs/cgroup/flakeos/pool"
          mkdir -p "$CG"
          echo ${cfg.memPerInstance} > "$CG/memory.max"
          echo ${cfg.memPerInstance} > "$CG/memory.high"
          echo 100000 > "$CG/cpu.max"
          echo ${cfg.cpuPerInstance}0000 > "$CG/cpu.max"
          echo 512 > "$CG/pids.max"
          echo "8:0  ${cfg.storagePerInstance}" > "$CG/io.max"
        '';
      };
      flakeos-pool = {
        description = "MicroVM Instance Pool";
        after = [ "network.target" "microvm-host.service" "create-pool-zfs.service" ];
        wants = [ "microvm-host.service" ];
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [ microvm coreutils bash curl ];
        environment = {
          POOL_DIR = "/var/lib/instance-pool";
          BASE_PORT = toString cfg.basePort;
          MAX_INSTANCES = toString cfg.maxInstances;
          MEM_LIMIT = cfg.memPerInstance;
          CPU_LIMIT = cfg.cpuPerInstance;
          APP_COMMAND = cfg.appCommand or "";
          HEALTHCHECK_CMD = cfg.healthcheckCmd or "";
        };
        serviceConfig = {
          Type = "notify";
          Restart = "always";
          RestartSec = 5;
          StateDirectory = "instance-pool";
          NotifyAccess = "all";
          LimitNOFILE = 1048576;
          LimitNPROC = 1048576;
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
      virtualHosts."*.pool.flakeos.local" = {
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
