{ config, lib, pkgs, hardwareDB, ... }:
with lib;
let
  gpuVendor = config.flakeos.hardware.gpuVendor;
  gpuCfg = hardwareDB.gpu.${gpuVendor} or hardwareDB.gpu.amd;
  nvidiaCfg = config.flakeos.hardware.nvidia;
in
{
  options.flakeos.hardware = {
    enable = mkOption { type = types.bool; };
    gpuVendor = mkOption {
      type = types.enum [ "nvidia" "amd" "intel" ];
      description = "GPU vendor for optimal drivers";
    };
    enableNvidiaPrime = mkOption {
      type = types.bool;
      description = "Enable NVIDIA Optimus/PRIME (laptop)";
    };
    nvidia = {
      modesetting = mkOption { type = types.bool; };
      powerManagement = mkOption { type = types.bool; };
      powerManagementFinegrained = mkOption { type = types.bool; };
      openDriver = mkOption { type = types.bool; };
      nvidiaSettings = mkOption { type = types.bool; };
      enableOffloadCmd = mkOption { type = types.bool; };
    };
    graphics = {
      enable = mkOption { type = types.bool; };
      enable32Bit = mkOption { type = types.bool; };
      extraPackages = mkOption {
        type = types.listOf types.package;
      };
    };
    enableNvmeOptimizations = mkOption {
      type = types.bool;
      description = "Enable NVMe SSD optimizations (IO scheduler, power saving)";
    };
    enableThunderbolt = mkOption {
      type = types.bool;
      description = "Enable Thunderbolt and USB4 support (bolt daemon)";
    };
    enableFingerprint = mkOption {
      type = types.bool;
      description = "Enable fingerprint reader support (fprintd)";
    };
  };
  config = mkIf config.flakeos.hardware.enable {
    flakeos.hardware = {
      enable = mkDefault true;
      enableNvidiaPrime = mkDefault false;
      nvidia = {
        modesetting = mkDefault true;
        powerManagement = mkDefault true;
        powerManagementFinegrained = mkDefault false;
        openDriver = mkDefault false;
        nvidiaSettings = mkDefault false;
        enableOffloadCmd = mkDefault true;
      };
      graphics = {
        enable = mkDefault true;
        enable32Bit = mkDefault true;
        extraPackages = mkDefault (with pkgs;
          if gpuVendor == "intel" then [
            intel-media-driver
            vaapiIntel
            intel-compute-runtime
            libva
            libvdpau-va-gl
          ] else if gpuVendor == "nvidia" then [
            libva-vdpau-driver
            nvidia-vaapi-driver
            libva
          ] else [
            mesa
            libva
          ]);
      };
      enableNvmeOptimizations = mkDefault false;
      enableThunderbolt = mkDefault false;
      enableFingerprint = mkDefault false;
    };
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
    boot.kernelParams = gpuCfg.kernelParams
      ++ optionals config.flakeos.hardware.enableNvmeOptimizations [
      "nvme_core.default_ps_max_latency_us=0"
    ];
    environment.sessionVariables = gpuCfg.env;
    hardware.graphics = {
      enable = config.flakeos.hardware.graphics.enable;
      enable32Bit = config.flakeos.hardware.graphics.enable32Bit;
      extraPackages = config.flakeos.hardware.graphics.extraPackages;
    };
    services.hardware.bolt = mkIf config.flakeos.hardware.enableThunderbolt {
      enable = true;
    };
    services.fprintd = mkIf config.flakeos.hardware.enableFingerprint {
      enable = true;
      tod.enable = true;
    };
  };
}
