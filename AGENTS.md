BORA NixOS AgentiC Rules and Sprint Definitions
Strict Hard Zero Hardcoding Zero Comments Zero Inline Shell
Version 2.0.0 Sprint Foundation

The repository directory tree follows this structure. The root contains flake.nix which is the stateless pure entry point. configuration.nix is the module loader that performs dynamic auto scan. AGENTS.md is this file with agentic rules and sprint definitions. lib contains Nix libraries with pure functions exported by default.nix hardware.nix for CPU GPU and platform auto detection and spring.nix for the DI IoC Container with Circuit Breaker. src contains the NixOS source with hosts for per machine host definitions profiles for per use case profile definitions modules organized by category guests for MicroVM guest definitions config for runtime config files scripts for shell scripts assets for static assets secrets for secrets encrypted with SOPS and age tests for Nix tests and docs for documentation.

The architectural principles are as follows. Single responsibility means every Nix file has one purpose. No side effects means lib functions are pure with no side effects. Auto discovery means configuration.nix scans src/modules without manual imports. Parameterization means everything uses options with mkOption without hardcoding. External shell means shell scripts in scripts referenced via builtins.readFile. External config means config files in config referenced via relative path.

Rule 1 is Zero Comments in Nix files. Inline hash comments are forbidden. Block slash asterisk comments are forbidden. Multi line comments are forbidden. Technical documentation goes in AGENTS.md and user documentation in docs. Only AGENTS.md and files in docs may contain text.

Rule 2 is Zero Shell Inline in Nix. Writing shell scripts inside quoted Nix strings is forbidden. Using pkgs.writeShellScript with inline strings is forbidden. Using shell expressions inside Nix strings is forbidden. Every shell script must be in scripts as a separate file. The correct reference is pkgs.writeShellScriptBin name with builtins.readFile reading the script path.

Rule 3 is Zero Hardcoding. Hardcoding usernames like alessio or kairosci is forbidden. Hardcoding hostnames like bora or os is forbidden. Hardcoding paths IPs ports or UUIDs is forbidden. Hardcoding CPU GPU or RAM config is forbidden. Username must come from meta.nix or option. Hostname must come from meta.nix or option. Hardware must use options with lib.mkDefault. Activation must use lib.mkIf. No literal values every value must be a variable.

Rule 4 is Structural Atomicity. Every modification must produce an atomic new generation. Workarounds fallbacks and placeholders are forbidden. TODO FIXME and HACK are forbidden. Comments to disable code are forbidden. To disable a module use mkIf false. An unimplemented function must not exist.

Rule 5 is Dynamic Modularity. configuration.nix scans src/modules automatically. Each category corresponds to src/modules/category. Each category has default.nix which imports submodules. Modules are enabled via mkIf cfg.enable. Profiles activate combinations of modules. To create a new module create src/modules/category/name.nix update src/modules/category/default.nix define options with enable and parameters and use mkIf cfg.enable for config.

All host specific parameters are declared in src/hosts/hostname/meta.nix and injected via specialArgs. The generic meta.nix template contains system as system architecture hardware as hardware type profile as usage profile hostname as host name and username as user name. The substitution rules are that username in users.users becomes the username value username in home paths becomes home with username hostname in networking.hostName becomes the hostname value hostname in spring.application.name becomes the hostname value persist in environment.persistence reads from option and absolute paths for config and scripts are relative paths.

Sprint 1 is Foundation with the goal of creating the base system structure. It includes flake.nix as pure entry point with declarative inputs configuration.nix as auto scan module loader lib/default.nix exporting all libraries lib/hardware.nix as CPU GPU and Platform database src/modules/core for Boot Nix Locale and Sysctl src/hosts/hostname with meta default and hardware and AGENTS.md.

Sprint 2 is Filesystem and Immutability with the goal of implementing ZFS Impermanence and Disko. It includes the zfs module for pool ARC and snapshot the impermanence module for persist config desktop for external config files sanoid for automatic snapshot retention and disko for declarative partitioning.

Sprint 3 is Security with the goal of implementing extreme hardening firewall and SSH. It includes the firewall module with nftables default drop the external nftables configuration the hardening module for kernel and AppArmor the ssh module with keys only LAN only and audit logging with fail2ban.

Sprint 4 is Hardware Detection with the goal of auto configuring CPU GPU and Platform. It includes the cpu module for Intel AMD and ARM the gpu module for NVIDIA AMD and Intel the platform module for Desktop Laptop and Server and lib/hardware.nix as vendor optimization database.

Sprint 5 is Desktop and Bora Layout with the goal of creating minimal KDE Plasma 6 with original Bora layout. It includes the kde-minimal module for essential Plasma 6 the maclike module for the Bora theme the pipewire module for audio the maclike scripts for init and finalize shell and the desktop config files for plasma-appletsrc kdeglobals and kwinrc.

Sprint 6 is Container Engine with the goal of creating the container engine with hardware level isolation. It includes the microvm-host module for host and bridge the orchestrator module for pool manager the sandbox guest as generic template the containers configuration for bridge and networking and SocketVM for desktop apps with X11 and Wayland forwarding.

Sprint 7 is Spring Framework with the goal of implementing Dependency Injection and Circuit Breaker. It includes lib/spring.nix for bean definitions topological sort mkSystemdService with resource limits circuit breaker with failure success and state circular dependency detection and the spring scripts for cgroup-init circuit-breaker and health. It also includes the orchestrator update to use Spring beans.

Sprint 8 is Instance Pool Orchestrator with the goal of creating the pool of isolated instances for any application. It includes the instance-pool module with pool options the guest definition per application the pool configuration the pool scripts for pool-manager spawn list and stats cgroup v2 for per instance resource isolation and Caddy reverse proxy for routing to instances.

Sprint 9 is Testing and Documentation with the goal of implementing pure Nix tests and complete documentation. It includes tests/default.nix for pure library tests tests/shell.nix for linting environment with statix and deadnix docs/BORA-WP.md as user manual in text format AGENTS.md with always updated agentic rules and ISO generation for immediate deploy.

The sprint flow proceeds from Sprint 1 to Sprint 2 to Sprint 3 to Sprint 4 from which it branches to Sprint 5 which continues to Sprint 6 which leads to Sprint 7 and Sprint 8 and finally Sprint 9. Each sprint produces a working NixOS generation without unsatisfied dependencies.

The sprint history records all completions. All sprints from number 1 to number 9 are completed. The system is ready for build and deploy.

Bean definition happens via bora.spring.beans.name with attributes enable to enable class as service type deps as list of beans it depends on resources with cpu memory memoryMax pids ioRbps ioWbps and numa healthcheck as command to verify status dependsOn for systemd dependencies after for systemd ordering and restartPolicy for restart policy.

The Circuit Breaker state machine has three states. CLOSED is normal operation where requests pass through and failures increment a counter. OPEN is open circuit where requests are blocked and a timeout timer starts. HALF-OPEN is recovery test where limited requests are allowed. Transitions are that CLOSED transitions to OPEN when failures reach the threshold which defaults to 5. OPEN transitions to HALF-OPEN after the timeout which defaults to 30 seconds. HALF-OPEN transitions to CLOSED when successes reach the threshold which defaults to 2. HALF-OPEN transitions to OPEN when a failure occurs in half-open.

Topological sort resolves dependencies between beans at build time. If a cycle exists the build fails with an error message indicating circular dependency in the specified beans.

The cgroup v2 hierarchy is organized under sys fs cgroup with the host name containing bean-database bean-redis and bean-webapp with cpu.max memory.max pids.max and io.max and OOM policy kill. The bora section contains pool for MicroVM instances with instance-001 and instance-002 with cpu.max at 50 percent and memory.max at 256 MB.

OOM protection provides OOMPolicy kill for all Spring services. MemoryHigh is the soft limit for throttling before OOM. MemoryMax is the hard limit for OOM kill if exceeded. DefaultMemoryAccounting is yes globally. The health check flow executes the healthcheck command. If the result is success it calls circuit_success. If the result is failure it calls circuit_trip. In CLOSED state it increments the counter and if it exceeds the threshold transitions to OPEN. In OPEN state it waits for the timeout then transitions to HALF-OPEN. In HALF-OPEN state if the attempt count is below the maximum it retries otherwise transitions to CLOSED. If the circuit is OPEN the service does not start and exits with code 1.

The kernel sysctl parameters include kernel.kptr_restrict set to 2 kernel.dmesg_restrict to 1 kernel.perf_event_paranoid to 3 kernel.yama.ptrace_scope to 2 kernel.randomize_va_space to 2 kernel.unprivileged_bpf_disabled to 1 net.core.bpf_jit_enable to 0 kernel.kexec_load_disabled to 1 and kernel.sysrq to 0.

The nftables firewall defines chain input with policy DROP accepting established and related connections loopback interface traffic ICMP with rate limit of 10 per second and TCP port 22 from LAN addresses and logging and dropping everything else. chain forward with policy DROP accepts established and related connections and traffic from the microvm interface. chain output with policy ACCEPT.

SSH hardening provides PermitRootLogin no PasswordAuthentication no PubkeyAuthentication yes MaxAuthTries 3 MaxSessions 4 AllowTcpForwarding no AllowAgentForwarding no ciphers ChaCha20-Poly1305 and AES-256-GCM and MACs HMAC-SHA2-512-ETM and HMAC-SHA2-256-ETM. AppArmor is enforced with active cache profiles from apparmor-profiles and lockdown set to confidentiality.

The idempotency rules require that nixos-rebuild switch is idempotent running it twice in a row must produce the same result. There must be no side effects outside the nix store. The etc directory is regenerated on every build. User state resides only in persist and home. The root filesystem is ephemeral via impermanence.

Regarding atomicity every nixos-rebuild produces a new generation. The previous generation remains intact in the boot menu. Rollback is performed with nixos-rebuild switch rollback. ZFS performs automatic pre rebuild snapshot and post rebuild snapshot via sanoid. Workarounds attempts hacks and placeholders have zero tolerance.

Rule 6 is Pull Request Only. Direct commits and pushes to the main branch are forbidden. Every change must go through a pull request on GitHub. All CI jobs must pass before merge. The only exception is the chore initial commit on main which is created manually once. No agent or developer pushes directly to main.

Rule 7 is CI on PR Only. The CI workflow triggers exclusively on pull requests targeting main. Push triggers are forbidden except for release tags. The CI must run linting evaluation tests hardware validation and security audit. Every job must produce a pass or fail result with no skipped steps. ISO generation is not part of CI. ISO build happens only in the release workflow triggered by version tags or locally via scripts/build/iso-build.sh.

The mandatory quality gates before each merge include statix check src for Nix linting deadnix src for dead code detection nixpkgs-fmt check src for formatting nix-instantiate --eval --strict tests/default.nix for library tests and nix-instantiate --eval --strict tests/modules.nix for module integration tests. The merge must be blocked if any of the quality gates fails.

The test structure provides tests/default.nix for testing lib functions with testHardwareDetect testSpringFramework testCoreModules and testSecurityModules and tests/modules.nix for module integration tests with concrete host and profile configurations. Every module that defines options must have assertions that verify conditions with error message. Every test case must be a real world scenario not a placeholder or sample.

The CI workflow defines three sequential phases. Phase 1 is lint with statix deadnix and nixpkgs-fmt running in parallel on the same runner. Phase 2 is eval-tests with nix-instantiate --eval --strict on all test files. Phase 3 is security-audit with nix-instantiate --eval on the hardened configuration to verify sysctl firewall and SSH parameters are applied correctly.

When the user requests a modification the agent searches src/modules for the relevant module. If it does not exist it creates a new category creates default.nix and creates the module file. Then it modifies options and config. If shell scripts are needed they go in scripts never inline. If config files are needed they go in config never inline. If hardcoding exists it is replaced with options mkDefault and mkIf. If comments exist in Nix files they are removed and placed in AGENTS.md. Then it runs statix deadnix and nixpkgs-fmt. It verifies idempotency. Every modification must be submitted as a pull request on the alpha branch targeting main. Direct commits to main are forbidden.

The rules for the agent are as follows. Never write comments in Nix files. Never write shell scripts inline in Nix files. Never hardcode username hostname or path. Never commit or push to main directly. Always use options with mkOption for parameters. Always use mkIf for conditional activation. Always use mkDefault for overridable defaults. Always submit changes through a pull request from alpha to main. Shell scripts in scripts. Config files in config. Technical documentation in AGENTS.md. User documentation in docs. After every modification run statix deadnix and nixpkgs-fmt. Every modification must be idempotent.

The template for a new module requires defining config lib pkgs using let cfg config.bora.category.module to access options. options.bora.category.module must contain enable as mkEnableOption and option1 as mkOption with type and default. config must be wrapped in mkIf cfg.enable with attr set to mkDefault cfg.option1.

The template for a new host requires a meta.nix file with system hardware profile hostname and username. The default.nix file receives config lib pkgs username and hostname and configures networking.hostName with hostname and users.users with username as isNormalUser true and extraGroups with wheel.

The template for a shell script requires the file in scripts/category/name.sh with bash shebang set euo pipefail parameters with defaults and main function that executes the logic. The reference in Nix uses pkgs.writeShellScriptBin with builtins.readFile to read the script path.

BORA NixOS AgentiC Rules v2.0.0 Sprint Foundation
Copyright 2026 Distributed under MIT license
