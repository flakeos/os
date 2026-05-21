{ config, lib, ... }:
with lib;
let cfg = config.flakeos.containers.bridge; in {
  options.flakeos.containers.bridge = {
    subnet = mkOption { type = types.str; };
    interface = mkOption { type = types.str; };
    nat = mkOption { type = types.bool; };
  };
  config = {
    flakeos.containers.bridge = {
      subnet = mkDefault "10.100.0.0/24";
      interface = mkDefault "microvm";
      nat = mkDefault true;
    };
    microvm.host.network = {
      enable = true;
      nat = cfg.nat;
      subnet = cfg.subnet;
      bridge = cfg.interface;
    };
  };
}
