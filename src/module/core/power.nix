{ config, lib, ... }:
with lib;
let cfg = config.flakeos.core.power; in {
  options.flakeos.core.power = {
    enable = mkEnableOption "System power and reliability management";
    thermald = {
      enable = mkOption { type = types.bool; default = true; };
    };
    earlyoom = {
      enable = mkOption { type = types.bool; default = true; };
    };
    panicTimeout = mkOption { type = types.int; default = 10; };
    enableOopsPanic = mkOption { type = types.bool; default = false; };
    enableCrashDump = mkOption { type = types.bool; default = false; };
    cpuFreqGovernor = mkOption { type = types.str; };
  };
  config = mkIf cfg.enable {
    boot.kernelParams =
      (optional (cfg.panicTimeout > 0) "panic=${toString cfg.panicTimeout}")
      ++ optional cfg.enableOopsPanic "oops=panic";
    services.thermald.enable = cfg.thermald.enable;
    services.earlyoom = {
      enable = cfg.earlyoom.enable;
      enableNotifications = true;
    };
    powerManagement.cpuFreqGovernor = mkDefault cfg.cpuFreqGovernor;
  };
}
