{ config, lib, pkgs, hardwareDB, ... }:
with lib;
let
  gpuVendor = config.flakeos.hardware.gpuVendor or "amd";
  gpuCfg = hardwareDB.gpu.${gpuVendor} or hardwareDB.gpu.amd;
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
  };
  config = {
    services.xserver.videoDrivers = gpuCfg.drivers;
    hardware.nvidia = mkIf (gpuVendor == "nvidia") {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = false;
      prime = {
        sync.enable = config.flakeos.hardware.enableNvidiaPrime;
        offload = {
          enable = !config.flakeos.hardware.enableNvidiaPrime;
          enableOffloadCmd = true;
        };
      };
    };
    boot.kernelParams = gpuCfg.kernelParams;
    environment.sessionVariables = gpuCfg.env;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        (if gpuVendor == "intel" then intel-media-driver
        else libva-vdpau-driver)
      ];
    };
  };
}
