{ config, lib, ... }:
with lib;
let cfg = config.flakeos.containers.microvm; in {
  options.flakeos.containers.microvm = {
    enable = mkEnableOption "MicroVM host support";
    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/microvm";
      description = "Directory for MicroVM storage";
    };
  };
  config = mkIf cfg.enable {
    microvm = {
      host.enable = true;
      inherit (cfg) stateDir;
    };
    fileSystems.${cfg.stateDir} = {
      device = "zroot/root/microvm";
      fsType = "zfs";
      neededForBoot = true;
    };
    boot.kernelModules = [ "virtio" "virtio_net" "virtio_blk" "virtiofs" "virtio_gpu" ];
    boot.initrd.kernelModules = [ "virtiofs" ];
    users.groups.microvm = { };
  };
}
