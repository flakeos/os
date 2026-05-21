{ config, lib, ... }:
with lib;
let cfg = config.flakeos.containers.bridge; in {
  options.flakeos.containers.bridge = {
    subnet = mkOption { type = types.str; default = "10.100.0.0/24"; };
    interface = mkOption { type = types.str; default = "microvm"; };
    nat = mkOption { type = types.bool; default = true; };
  };
  config = {
    microvm.host.network = {
      enable = true;
      nat = cfg.nat;
      subnet = cfg.subnet;
      bridge = cfg.interface;
    };
  };
}
