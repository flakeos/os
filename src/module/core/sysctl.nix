{ config, lib, ... }:
with lib;
let cfg = config.flakeos.core.sysctl; in {
  options.flakeos.core.sysctl = {
    enable = mkEnableOption "Kernel sysctl hardening";
    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {
        "kernel.kptr_restrict" = 2;
        "kernel.dmesg_restrict" = 1;
        "kernel.perf_event_paranoid" = 3;
        "kernel.yama.ptrace_scope" = 2;
        "kernel.randomize_va_space" = 2;
        "kernel.unprivileged_bpf_disabled" = 1;
        "net.core.bpf_jit_enable" = 0;
        "kernel.kexec_load_disabled" = 1;
        "kernel.sysrq" = 0;
        "net.ipv4.tcp_syncookies" = 1;
        "net.ipv4.conf.all.rp_filter" = 1;
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.secure_redirects" = 0;
        "net.ipv4.conf.default.secure_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        "net.ipv4.icmp_echo_ignore_all" = 0;
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
        "net.ipv4.tcp_rfc1337" = 1;
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_expire_centisecs" = 3000;
        "vm.dirty_writeback_centisecs" = 500;
        "vm.max_map_count" = 2147483642;
        "kernel.numa_balancing" = 0;
        "fs.file-max" = 9223372036854775807;
        "fs.inotify.max_user_watches" = 1048576;
        "fs.inotify.max_user_instances" = 1048576;
        "fs.inotify.max_queued_events" = 1048576;
        "fs.aio-max-nr" = 1048576;
        "net.core.somaxconn" = 65535;
        "net.core.netdev_max_backlog" = 5000;
        "net.core.rmem_max" = 134217728;
        "net.core.wmem_max" = 134217728;
        "net.ipv4.tcp_rmem" = "4096 87380 134217728";
        "net.ipv4.tcp_wmem" = "4096 65536 134217728";
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_fin_timeout" = 15;
        "net.ipv4.tcp_keepalive_time" = 300;
        "net.ipv4.tcp_keepalive_probes" = 5;
        "net.ipv4.tcp_keepalive_intvl" = 15;
        "net.ipv4.tcp_mtu_probing" = 1;
        "net.ipv4.tcp_slow_start_after_idle" = 0;
        "vm.overcommit_memory" = 1;
        "vm.oom_kill_allocating_task" = 0;
        "vm.panic_on_oom" = 0;
      };
    };
    disableCoredump = mkOption { type = types.bool; default = true; };
  };
  config = mkIf cfg.enable {
    boot.kernel.sysctl = cfg.settings;
    systemd.coredump.enable = !cfg.disableCoredump;
  };
}
