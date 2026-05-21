{ config, lib, ... }:
with lib;
let cfg = config.flakeos.containers.microvm; in {
  options.flakeos.containers.microvm = {
    enable = mkEnableOption "MicroVM host support";
    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/microvm";
    };
    zfsDataset = mkOption {
      type = types.str;
      default = "zroot/root/microvm";
    };
    kernelModules = mkOption {
      type = types.listOf types.str;
      default = [ "virtio" "virtio_net" "virtio_blk" "virtiofs" "virtio_gpu" ];
    };
    initrdKernelModules = mkOption {
      type = types.listOf types.str;
      default = [ "virtiofs" ];
    };
  };
  config = mkIf cfg.enable {
    microvm = {
      host.enable = true;
      inherit (cfg) stateDir;
    };
    fileSystems.${cfg.stateDir} = {
      device = cfg.zfsDataset;
      fsType = "zfs";
      neededForBoot = true;
    };
    boot.kernelModules = cfg.kernelModules;
    boot.initrd.kernelModules = cfg.initrdKernelModules;
    users.groups.microvm = { };
  };
}
