{ system ? builtins.currentSystem }:

let
  pkgs = import <nixpkgs> { inherit system; };
  nixpkgs = pkgs;
  boraLib = import ../lib { inherit nixpkgs; };
in {
  libTests = with boraLib; {
    testHardwareDetect = {
      cpuIntel = hardware.cpu.intel.name == "Intel";
      cpuAMD = hardware.cpu.amd.name == "AMD";
      gpuNvidia = hardware.gpu.nvidia.name == "NVIDIA";
      profileDesktop = (hardware.profileOpts.desktop).powerManagement.enable;
    };
    testSpringFramework = {
      beanGraph = true;
      cgroupConfig = true;
    };
  };
}
