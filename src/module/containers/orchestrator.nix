{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.orchestrator;
  orchestratorScript = pkgs.writeShellScriptBin "flakeos-orchestrator"
    (builtins.readFile ./../../scripts/containers/orchestrator.sh);
in
{
  options.flakeos.orchestrator = {
    enable = mkEnableOption "MicroVM instance orchestrator";
    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/flakeos-orchestrator";
    };
    microvmDir = mkOption {
      type = types.str;
      default = "/var/lib/microvm";
    };
    cgroupParent = mkOption {
      type = types.str;
      default = "/sys/fs/cgroup/flakeos";
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
        ExecStart = "${orchestratorScript}/bin/flakeos-orchestrator ${cfg.stateDir} ${cfg.cgroupParent} ${cfg.microvmDir} 30";
      };
    };
  };
}
