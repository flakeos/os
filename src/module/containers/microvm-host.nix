{ config, lib, ... }:
with lib;
let cfg = config.flakeos.containers.microvm; in {
  options.flakeos.containers.microvm = {
    enable = mkOption { type = types.bool; };
    stateDir = mkOption { type = types.path; };
    zfsDataset = mkOption { type = types.str; };
    kernelModules = mkOption { type = types.listOf types.str; };
    initrdKernelModules = mkOption { type = types.listOf types.str; };
  };
  config = mkIf cfg.enable {
    flakeos.containers.microvm = {
      stateDir = mkDefault "/var/lib/microvm";
      zfsDataset = mkDefault "zroot/root/microvm";
      kernelModules = mkDefault [ "virtio" "virtio_net" "virtio_blk" "virtiofs" "virtio_gpu" ];
      initrdKernelModules = mkDefault [ "virtiofs" ];
    };
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
