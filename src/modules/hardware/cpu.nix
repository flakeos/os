{ config, lib, hardwareDB, ... }:
with lib;
let
  cpuVendor = config.bora.hardware.cpuVendor or "intel";
  cpuCfg = hardwareDB.cpu.${cpuVendor} or hardwareDB.cpu.intel;
in
{
  options.bora.hardware = {
    cpuVendor = mkOption {
      type = types.enum [ "intel" "amd" "arm" ];
      default = "intel";
      description = "CPU vendor for optimal settings";
    };
    enableMitigations = mkOption {
      type = types.bool;
      default = true;
      description = "Enable CPU vulnerability mitigations";
    };
  };
  config = {
    hardware.cpu.intel.updateMicrocode = mkIf (cpuVendor == "intel") true;
    hardware.cpu.amd.updateMicrocode = mkIf (cpuVendor == "amd") true;
    boot.kernelModules = cpuCfg.kernelModules;
    boot.kernelParams = cpuCfg.kernelParams
      ++ (if config.bora.hardware.enableMitigations
    then [ "mitigations=auto" ]
    else [ "mitigations=off" ]);
    powerManagement.cpuFreqGovernor = mkDefault cpuCfg.power.governor;
  };
}
