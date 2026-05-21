{ config, lib, ... }:
with lib;
let
  cfg = config.flakeos.orchestrator;
in
{
  options.flakeos.orchestrator = {
    enable = mkEnableOption "MicroVM instance orchestrator";
    maxInstances = mkOption {
      type = types.int;
      default = 10000;
      description = "Maximum number of simultaneous MicroVM instances";
    };
    defaultMem = mkOption {
      type = types.int;
      default = 256;
      description = "Default memory per instance (MB)";
    };
    defaultVcpu = mkOption {
      type = types.int;
      default = 1;
      description = "Default vCPUs per instance";
    };
    portRange = mkOption {
      type = types.str;
      default = "8443-18443";
      description = "Port range for exposed services";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.flakeos-orchestrator = {
      description = "FlakeOS MicroVM Orchestrator";
      after = [ "microvm-host.service" "network.target" ];
      wants = [ "microvm-host.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 10;
        StateDirectory = "flakeos-orchestrator";
      };
      script = ''
        set -euo pipefail
        STATE_DIR="/var/lib/flakeos-orchestrator"
        mkdir -p "$STATE_DIR"
        echo "+cpu +memory +io +pids" > /sys/fs/cgroup/cgroup.subtree_control 2>/dev/null || true
        mkdir -p /sys/fs/cgroup/flakeos 2>/dev/null || true
        while true; do
          for vm in /var/lib/microvm/*/; do
            [ -d "$vm" ] || continue
            vm_name=$(basename "$vm")
            echo "checking microvm $vm_name"
          done
          sleep 30
        done
      '';
    };
  };
}
