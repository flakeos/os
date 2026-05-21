{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.orchestrator;
  orchestratorScript = pkgs.writeShellScriptBin "flakeos-orchestrator"
    (builtins.readFile ./../../scripts/containers/orchestrator.sh);
in
{
  options.flakeos.orchestrator = {
    enable = mkOption { type = types.bool; };
    stateDir = mkOption { type = types.str; };
    microvmDir = mkOption { type = types.str; };
    cgroupParent = mkOption { type = types.str; };
    checkInterval = mkOption { type = types.int; };
    serviceType = mkOption { type = types.str; };
    serviceRestart = mkOption { type = types.str; };
    serviceRestartSec = mkOption { type = types.int; };
    stateDirectory = mkOption { type = types.str; };
  };
  config = mkIf cfg.enable {
    flakeos.orchestrator = {
      stateDir = mkDefault "/var/lib/flakeos-orchestrator";
      microvmDir = mkDefault "/var/lib/microvm";
      cgroupParent = mkDefault "/sys/fs/cgroup/flakeos";
      checkInterval = mkDefault 30;
      serviceType = mkDefault "simple";
      serviceRestart = mkDefault "always";
      serviceRestartSec = mkDefault 10;
      stateDirectory = mkDefault "flakeos-orchestrator";
    };
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
