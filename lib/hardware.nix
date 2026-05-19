{ lib }:
let
  inherit (lib) mkIf mkDefault mkMerge toList;
in rec {
  cpu = {
    intel = {
      name = "Intel";
      microcode = [ "intel-microcode" ];
      kernelModules = [ "kvm-intel" "intel_rapl" "intel_uncore" ];
      kernelParams = [
        "intel_idle.max_cstate=4"
        "processor.max_cstate=4"
      ];
      power = {
        governor = "powersave";
        energy_perf_bias = "powersave";
      };
      hardening = {
        mitigations = "auto";
        nosmt = false;
      };
    };
    amd = {
      name = "AMD";
      microcode = [ "linux-firmware" ];
      kernelModules = [ "kvm-amd" "amd_rapl" "amd_pstate" ];
      kernelParams = [
        "amd_pstate=active"
        "amd_prefcore=enable"
      ];
      power = {
        governor = "schedutil";
        energy_perf_bias = "normal";
      };
      hardening = {
        mitigations = "auto";
        nosmt = false;
      };
    };
    arm = {
      name = "ARM";
      microcode = [ ];
      kernelModules = [ "arm-cpufreq" ];
      kernelParams = [ ];
      power.governor = "ondemand";
      hardening.mitigations = "auto";
    };
  };
  gpu = {
    nvidia = {
      name = "NVIDIA";
      drivers = [ "nvidia" ];
      env = {
        WLR_NO_HARDWARE_CURSORS = "1";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
      kernelParams = [ "nvidia_drm.fbdev=1" ];
      prime = {
        sync = false;
        offload = true;
      };
    };
    amd = {
      name = "AMD";
      drivers = [ "amdgpu" ];
      env = {
        RADV_PERFTEST = "ngc";
        ACO_DEBUG = "force-misched";
      };
      kernelParams = [
        "amdgpu.noreplay=0"
        "amdgpu.dcdebugmask=0x10"
      ];
    };
    intel = {
      name = "Intel";
      drivers = [ "modesetting" ];
      env = { };
      kernelParams = [
        "i915.enable_psr=1"
        "i915.enable_fbc=1"
        "i915.fastboot=1"
      ];
    };
  };
  profileOpts = {
    desktop = {
      powerManagement.enable = true;
      powerManagement.cpuFreqGovernor = "performance";
      services.power-profiles-daemon.enable = false;
    };
    laptop = {
      powerManagement.enable = true;
      powerManagement.cpuFreqGovernor = "powersave";
      services.power-profiles-daemon.enable = true;
      services.tlp.enable = true;
      services.auto-cpufreq.enable = true;
      boot.kernelParams = [ "acpi_osi=Linux" ];
    };
    server = {
      powerManagement.enable = false;
      powerManagement.cpuFreqGovernor = "performance";
      services.power-profiles-daemon.enable = false;
      services.tlp.enable = false;
      boot.kernelParams = [ "nmi_watchdog=0" "nowatchdog" ];
    };
  };
  gpuConfig = vendor: gpu.${vendor} or gpu.amd;
  cpuConfig = vendor: cpu.${vendor} or cpu.intel;
}
