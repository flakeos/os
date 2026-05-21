{ system ? builtins.currentSystem, nixpkgs ? import <nixpkgs> { inherit system; } }:

let
  inherit (nixpkgs) lib;
  flakeosLib = import ../lib { inherit nixpkgs; };
  hw = flakeosLib.hardware;

  inherit (builtins) toString;

  assertEq = name: actual: expected:
    if actual == expected
    then { ${name} = { ok = true; }; }
    else { ${name} = { ok = false; inherit expected actual; }; };

in

(
  let
    cpuVendors = hw.cpu;
    gpuVendors = hw.gpu;
    profiles = hw.profileOpts;
  in

  {
    testCpuIntel = assertEq "cpu.intel.name" cpuVendors.intel.name "Intel";
    testCpuIntelModules = assertEq "cpu.intel.kernelModules" cpuVendors.intel.kernelModules [ "kvm-intel" "intel_rapl" "intel_uncore" ];

    testCpuAMD = assertEq "cpu.amd.name" cpuVendors.amd.name "AMD";
    testCpuAMDModules = assertEq "cpu.amd.kernelModules" cpuVendors.amd.kernelModules [ "kvm-amd" "amd_rapl" "amd_pstate" ];

    testCpuARM = assertEq "cpu.arm.name" cpuVendors.arm.name "ARM";

    testGpuConfig = assertEq "gpuConfig nvidia" (hw.gpuConfig "nvidia").name "NVIDIA";
    testCpuConfig = assertEq "cpuConfig intel" (hw.cpuConfig "intel").name "Intel";

    testGpuConfigFallback = assertEq "gpuConfig unknown->amd" (hw.gpuConfig "unknown").name "AMD";

    testGpuNvidia = assertEq "gpu.nvidia.name" gpuVendors.nvidia.name "NVIDIA";
    testGpuNvidiaDrivers = assertEq "gpu.nvidia.drivers" gpuVendors.nvidia.drivers [ "nvidia" ];
    testGpuNvidiaPrime = assertEq "gpu.nvidia.prime.sync" gpuVendors.nvidia.prime.sync false;
    testGpuNvidiaPrimeOffload = assertEq "gpu.nvidia.prime.offload" gpuVendors.nvidia.prime.offload true;

    testGpuAMD = assertEq "gpu.amd.name" gpuVendors.amd.name "AMD";
    testGpuAMDDrivers = assertEq "gpu.amd.drivers" gpuVendors.amd.drivers [ "amdgpu" ];

    testGpuIntel = assertEq "gpu.intel.name" gpuVendors.intel.name "Intel";
    testGpuIntelDrivers = assertEq "gpu.intel.drivers" gpuVendors.intel.drivers [ "modesetting" ];

    testProfileDesktop = assertEq "profileOpts.desktop.powerManagement.enable" profiles.desktop.powerManagement.enable true;
    testProfileLaptop = assertEq "profileOpts.laptop.powerManagement.enable" profiles.laptop.powerManagement.enable true;
    testProfileServer = assertEq "profileOpts.server.powerManagement.enable" profiles.server.powerManagement.enable false;
  }
) //

(
  let
    spring = import ../../lib/spring.nix { inherit lib; pkgs = nixpkgs; };

    healthyBeans = {
      webapp = { enable = true; class = "WebApp"; deps = [ "database" "cache" ]; };
      database = { enable = true; class = "Database"; deps = [ ]; };
      cache = { enable = true; class = "Cache"; deps = [ "database" ]; };
      queue = { enable = true; class = "Queue"; deps = [ "cache" ]; };
    };

    circularBeans = {
      a = { enable = true; class = "A"; deps = [ "b" ]; };
      b = { enable = true; class = "B"; deps = [ "c" ]; };
      c = { enable = true; class = "C"; deps = [ "a" ]; };
    };

    emptyBeans = { };

  in
  {
    testBeanGraphWebapp = assertEq "beanGraph.webapp.deps"
      (builtins.head (builtins.filter (e: e.name == "webapp") (spring.beanGraph healthyBeans))).deps
      [ "database" "cache" ];

    testBeanGraphDatabase = assertEq "beanGraph.database.deps"
      (builtins.head (builtins.filter (e: e.name == "database") (spring.beanGraph healthyBeans))).deps
      [ ];

    testTsortProducesAll = assertEq "tsort length"
      (builtins.length (spring.tsort (spring.beanGraph healthyBeans)))
      4;

    testTsortOrderValid =
      let
        sorted = spring.tsort (spring.beanGraph healthyBeans);
        names = map (n: n.name) sorted;
        dbIdx = builtins.elemAt (builtins.filter (i: builtins.elemAt names i == "database") (lib.genList (x: x) (builtins.length names))) 0;
        webappIdx = builtins.elemAt (builtins.filter (i: builtins.elemAt names i == "webapp") (lib.genList (x: x) (builtins.length names))) 0;
      in
      assertEq "tsort.database_before_webapp" (dbIdx < webappIdx) true;

    testCircularDetection = assertEq "detectCircular"
      (builtins.length (spring.detectCircular circularBeans) > 0)
      true;

    testCircularDetectionEmpty = assertEq "detectCircular.empty"
      (spring.detectCircular emptyBeans)
      [ ];

    testResolveConfig = assertEq "resolveBeanConfig"
      (builtins.length (builtins.attrNames (spring.resolveBeanConfig healthyBeans)))
      4;

    testMkSystemdService =
      let
        service = spring.mkSystemdService "testapp" "mybean" {
          enable = true;
          class = "MyClass";
          deps = [ ];
          resources = { cpu = "2"; memory = "512M"; memoryMax = "1G"; pids = 512; ioRbps = "200M"; ioRops = 2000; ioWbps = "200M"; ioWops = 2000; numa = null; };
          healthcheck = null;
          livenessProbe = null;
          startupProbe = null;
          dependsOn = [ ];
          after = [ ];
          wants = [ ];
          restartPolicy = "always";
          restartSec = 5;
          config = { };
          environment = { };
          serviceType = "simple";
          timeoutStartSec = 30;
          timeoutStopSec = 10;
        };
        name = builtins.head (builtins.attrNames service);
        def = builtins.head (builtins.attrValues service);
      in
      {
        testServiceName = assertEq "service.name" name "spring-testapp-mybean";
        testServiceType = assertEq "service.serviceConfig.Type" def.serviceConfig.Type "simple";
        testServiceRestart = assertEq "service.serviceConfig.Restart" def.serviceConfig.Restart "always";
        testServiceMemoryMax = assertEq "service.serviceConfig.MemoryMax" def.serviceConfig.MemoryMax "1G";
        testServiceMemoryHigh = assertEq "service.serviceConfig.MemoryHigh" def.serviceConfig.MemoryHigh "512M";
        testServiceCPUQuota = assertEq "service.serviceConfig.CPUQuota" def.serviceConfig.CPUQuota "20%";
        testServiceOOM = assertEq "service.serviceConfig.OOMPolicy" def.serviceConfig.OOMPolicy "kill";
        testServiceWantedBy = assertEq "service.wantedBy" def.wantedBy [ "multi-user.target" ];
        testServiceHasThat = assertEq "service.hasScript" (def ? script) true;
      };
  }
) //

(
  let
    flakeosLib = import ../lib { inherit nixpkgs; };
  in
  {
    testAtomicPreRebuildSnapshot = assertEq "atomic.preRebuildSnapshot"
      (flakeosLib.atomic.preRebuildSnapshot "tank" "root" != "")
      true;

    testAtomicBackupGeneration = assertEq "atomic.backupGeneration"
      (flakeosLib.atomic.backupGeneration != "")
      true;
  }
) //

(
  let
    spring = import ../../lib/spring.nix { inherit lib; pkgs = nixpkgs; };

    genChainBeans = n:
      let
        names = lib.genList (i: "bean-${toString i}") n;
        beans = builtins.listToAttrs (map
          (name: {
            inherit name;
            value = {
              enable = true;
              class = "Bean_${name}";
              deps = if name == "bean-0" then [ ] else [ "bean-${toString (builtins.fromJSON (builtins.elemAt (lib.splitString "-" name) 1) - 1)}" ];
            };
          })
          names);
      in
      beans;

    chain10 = genChainBeans 10;
    chain50 = genChainBeans 50;
    chain100 = genChainBeans 100;

    bench = name: beans:
      let
        start = builtins.currentTime or 0;
        graph = spring.beanGraph beans;
        sorted = spring.tsort graph;
        duration = if builtins ? currentTime then builtins.currentTime - start else 0;
        len = builtins.length sorted;
      in
      {
        ${name} = {
          ok = len == (builtins.length (builtins.attrNames beans));
          beans = len;
          duration_seconds = duration;
        };
      };
  in
  (bench "benchmark.tsort.chain10" chain10) //
  (bench "benchmark.tsort.chain50" chain50) //
  (bench "benchmark.tsort.chain100" chain100)
)
