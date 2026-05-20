_:
{
  imports = [ ./instance.nix ];

  flakeos.containers.instancePool = {
    enable = true;
    maxInstances = 899;
    basePort = 8443;
    memPerInstance = "256M";
    cpuPerInstance = "0.5";
    storagePerInstance = "2G";
  };
}
