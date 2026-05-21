{ config, lib, hardwareDB, ... }:
with lib;
let
  cpuVendor = config.flakeos.hardware.cpuVendor;
  cpuCfg = hardwareDB.cpu.${cpuVendor} or hardwareDB.cpu.intel;
in
{
  options.flakeos.hardware = {
    cpuVendor = mkOption {
      type = types.enum [ "intel" "amd" "arm" ];
      description = "CPU vendor for optimal settings";
    };
    enableMitigations = mkOption {
      type = types.bool;
      description = "Enable CPU vulnerability mitigations";
    };
    enableIntelMicrocode = mkOption { type = types.bool; };
    enableAmdMicrocode = mkOption { type = types.bool; };
  };
  config = {
    flakeos.hardware = {
      enableMitigations = mkDefault true;
      enableIntelMicrocode = mkDefault (cpuVendor == "intel");
      enableAmdMicrocode = mkDefault (cpuVendor == "amd");
    };
    hardware.cpu.intel.updateMicrocode =
      mkIf (cpuVendor == "intel") config.flakeos.hardware.enableIntelMicrocode;
    hardware.cpu.amd.updateMicrocode =
      mkIf (cpuVendor == "amd") config.flakeos.hardware.enableAmdMicrocode;
    boot.kernelModules = cpuCfg.kernelModules;
    boot.kernelParams = cpuCfg.kernelParams
      ++ (if config.flakeos.hardware.enableMitigations
    then [ "mitigations=auto" ]
    else [ "mitigations=off" ]);
    powerManagement.cpuFreqGovernor = mkDefault cpuCfg.power.governor;
  };
}
