{ config, lib, ... }:
with lib;
let cfg = config.flakeos.core.power; in {
  options.flakeos.core.power = {
    enable = mkOption { type = types.bool; };
    thermald = {
      enable = mkOption { type = types.bool; };
    };
    earlyoom = {
      enable = mkOption { type = types.bool; };
      enableNotifications = mkOption { type = types.bool; };
    };
    panicTimeout = mkOption { type = types.int; };
    enableOopsPanic = mkOption { type = types.bool; };
    enableCrashDump = mkOption { type = types.bool; };
    cpuFreqGovernor = mkOption { type = types.str; };
  };
  config = mkIf cfg.enable {
    flakeos.core.power = {
      thermald.enable = mkDefault true;
      earlyoom = {
        enable = mkDefault true;
        enableNotifications = mkDefault true;
      };
      panicTimeout = mkDefault 10;
      enableOopsPanic = mkDefault false;
      enableCrashDump = mkDefault false;
    };
    boot.kernelParams =
      (optional (cfg.panicTimeout > 0) "panic=${toString cfg.panicTimeout}")
      ++ optional cfg.enableOopsPanic "oops=panic";
    services.thermald.enable = cfg.thermald.enable;
    services.earlyoom = {
      enable = cfg.earlyoom.enable;
      enableNotifications = cfg.earlyoom.enableNotifications;
    };
    powerManagement.cpuFreqGovernor = mkDefault cfg.cpuFreqGovernor;
  };
}
