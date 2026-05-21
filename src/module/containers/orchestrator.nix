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
    checkInterval = mkOption {
      type = types.int;
      default = 30;
    };
    serviceType = mkOption { type = types.str; default = "simple"; };
    serviceRestart = mkOption { type = types.str; default = "always"; };
    serviceRestartSec = mkOption { type = types.int; default = 10; };
    stateDirectory = mkOption { type = types.str; default = "flakeos-orchestrator"; };
  };
  config = mkIf cfg.enable {
    systemd.services.flakeos-orchestrator = {
      description = "FlakeOS MicroVM Orchestrator";
      after = [ "microvm-host.service" "network.target" ];
      wants = [ "microvm-host.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = cfg.serviceType;
        Restart = cfg.serviceRestart;
        RestartSec = cfg.serviceRestartSec;
        StateDirectory = cfg.stateDirectory;
        ExecStart = "${orchestratorScript}/bin/flakeos-orchestrator ${cfg.stateDir} ${cfg.cgroupParent} ${cfg.microvmDir} ${toString cfg.checkInterval}";
      };
    };
  };
}
