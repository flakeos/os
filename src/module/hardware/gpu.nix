{ config, lib, pkgs, hardwareDB, ... }:
with lib;
let
  gpuVendor = config.flakeos.hardware.gpuVendor or "amd";
  gpuCfg = hardwareDB.gpu.${gpuVendor} or hardwareDB.gpu.amd;
  nvidiaCfg = config.flakeos.hardware.nvidia;
in
{
  options.flakeos.hardware = {
    gpuVendor = mkOption {
      type = types.enum [ "nvidia" "amd" "intel" ];
      default = "amd";
      description = "GPU vendor for optimal drivers";
    };
    enableNvidiaPrime = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NVIDIA Optimus/PRIME (laptop)";
    };
    nvidia = {
      modesetting = mkOption { type = types.bool; default = true; };
      powerManagement = mkOption { type = types.bool; default = true; };
      powerManagementFinegrained = mkOption { type = types.bool; default = false; };
      openDriver = mkOption { type = types.bool; default = false; };
      nvidiaSettings = mkOption { type = types.bool; default = false; };
      enableOffloadCmd = mkOption { type = types.bool; default = true; };
    };
    graphics = {
      enable = mkOption { type = types.bool; default = true; };
      enable32Bit = mkOption { type = types.bool; default = true; };
      extraPackages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [ (if gpuVendor == "intel" then intel-media-driver else libva-vdpau-driver) ];
      };
    };
  };
  config = {
    services.xserver.videoDrivers = gpuCfg.drivers;
    hardware.nvidia = mkIf (gpuVendor == "nvidia") {
      modesetting.enable = nvidiaCfg.modesetting;
      powerManagement.enable = nvidiaCfg.powerManagement;
      powerManagement.finegrained = nvidiaCfg.powerManagementFinegrained;
      open = nvidiaCfg.openDriver;
      nvidiaSettings = nvidiaCfg.nvidiaSettings;
      prime = {
        sync.enable = config.flakeos.hardware.enableNvidiaPrime;
        offload = {
          enable = !config.flakeos.hardware.enableNvidiaPrime;
          enableOffloadCmd = nvidiaCfg.enableOffloadCmd;
        };
      };
    };
    boot.kernelParams = gpuCfg.kernelParams;
    environment.sessionVariables = gpuCfg.env;
    hardware.graphics = {
      enable = config.flakeos.hardware.graphics.enable;
      enable32Bit = config.flakeos.hardware.graphics.enable32Bit;
      extraPackages = config.flakeos.hardware.graphics.extraPackages;
    };
  };
}
