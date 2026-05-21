{ config, lib, ... }:
{
  microvm.host.network = {
    enable = true;
    nat = true;
    subnet = "10.100.0.0/24";
    bridge = "microvm";
  };
}
