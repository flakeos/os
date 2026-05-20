# FLAKEOS NixOS AgentiC Rules

Strict Hard Zero Hardcoding Zero Comments Zero Inline Shell  
Version 2.1.0

## Architecture

The repository directory tree follows this structure. The root contains flake.nix which is the stateless pure entry point. configuration.nix is the module loader that performs dynamic auto scan. AGENTS.md is this file with agentic rules and sprint definitions. lib contains Nix libraries with pure functions exported by default.nix hardware.nix for CPU GPU and platform auto detection and spring.nix for the DI IoC Container with Circuit Breaker. src contains the NixOS source with hosts for per machine host definitions profiles for per use case profile definitions modules organized by category guests for MicroVM guest definitions config for runtime config files scripts for shell scripts assets for static assets secrets for secrets encrypted with SOPS and age tests for Nix tests and docs for documentation. .changelog contains per release changelog entries following conventional commits format.

The architectural principles are as follows. Single responsibility means every Nix file has one purpose. No side effects means lib functions are pure with no side effects. Auto discovery means configuration.nix scans src/modules without manual imports. Parameterization means everything uses options with mkOption without hardcoding. External shell means shell scripts in scripts referenced via builtins.readFile. External config means config files in config referenced via relative path.

## Conventional Commits

Every commit must follow the conventional commits specification. The format is type(scope): description. The body is optional and must be empty for squash merges. Valid types are feat for a new feature fix for a bug fix refactor for code restructuring docs for documentation changes chore for maintenance tasks test for testing changes ci for CI workflow changes style for formatting changes perf for performance improvements. The scope is the module or area affected such as core security desktop spring lib. Examples include feat(core): add sysctl hardening module fix(security): resolve nftables input chain order refactor(lib): clean up spring.nix unused params chore: add MIT license file ci: trigger release on version tags only.

## Rules

### Rule 1

Zero Comments in Nix files. Inline hash comments are forbidden. Block slash asterisk comments are forbidden. Multi line comments are forbidden. Technical documentation goes in AGENTS.md and user documentation in docs. Only AGENTS.md and files in docs may contain text.

### Rule 2

Zero Shell Inline in Nix. Writing shell scripts inside quoted Nix strings is forbidden. Using pkgs.writeShellScript with inline strings is forbidden. Using shell expressions inside Nix strings is forbidden. Every shell script must be in scripts as a separate file. The correct reference is pkgs.writeShellScriptBin name with builtins.readFile reading the script path.

### Rule 3

Zero Hardcoding. Hardcoding usernames like alessio or kairosci is forbidden. Hardcoding hostnames like flakeos or os is forbidden. Hardcoding paths IPs ports or UUIDs is forbidden. Hardcoding CPU GPU or RAM config is forbidden. Username must come from meta.nix or option. Hostname must come from meta.nix or option. Hardware must use options with lib.mkDefault. Activation must use lib.mkIf. No literal values every value must be a variable.

### Rule 4

Structural Atomicity. Every modification must produce an atomic new generation. Workarounds fallbacks and placeholders are forbidden. TODO FIXME and HACK are forbidden. Comments to disable code are forbidden. To disable a module use mkIf false. An unimplemented function must not exist.

### Rule 5

Dynamic Modularity. configuration.nix scans src/modules automatically. Each category corresponds to src/modules/category. Each category has default.nix which imports submodules. Modules are enabled via mkIf cfg.enable. Profiles activate combinations of modules. To create a new module create src/modules/category/name.nix update src/modules/category/default.nix define options with enable and parameters and use mkIf cfg.enable for config.

### Rule 6

Pull Request Only. Direct commits and pushes to the main branch are forbidden. Every change must go through a pull request on GitHub. All CI jobs must pass before merge. The only exception is the chore initial commit on main which is created manually once. No agent or developer pushes directly to main. Merges must use squash strategy. Merge commits must have an empty body and must not include the pull request number in the title.

### Rule 7

CI on PR Only. The CI workflow triggers exclusively on pull requests targeting main. Push triggers are forbidden except for release tags. The CI must run linting evaluation tests hardware validation and security audit. Every job must produce a pass or fail result with no skipped steps. ISO generation is not part of CI. ISO build happens only in the release workflow triggered by version tags or locally via scripts/build/iso-build.sh.

## Nix Best Practices

### Module Structure

Each module defines an options block with an enable flag and all configurable parameters. The config block is wrapped in mkIf cfg.enable. Assertions validate parameter combinations at evaluation time. Options must use mkOption with explicit type and default. Default values use mkDefault for overridability. Conditional values use mkIf. Host specific values are never hardcoded they come from meta.nix or specialArgs.

### Pure Functions

Library functions in lib must be pure with no side effects. They receive only their dependencies as function arguments. No config state or pkgs is accessible unless explicitly passed. Functions return values without modifying external state. Evaluation is deterministic and idempotent.

### Parameterization

Every configurable value uses Nix options with mkOption. Types must be explicit using types from lib.types. Defaults must be sensible and use mkDefault. Conditional overrides use mkIf. Assertions validate parameter combinations. Host specific values are injected via specialArgs from meta.nix.

### Testing

Tests evaluate pure library functions with assertEq. Module integration tests use nixosSystem with minimal configuration. Every module with options must have assertions. Test files live in tests and use strict evaluation. Test cases must be real world scenarios not placeholders.

## Host Specific Parameters

All host specific parameters are declared in src/hosts/hostname/meta.nix and injected via specialArgs. The generic meta.nix template contains system as system architecture hardware as hardware type profile as usage profile hostname as host name and username as user name. The substitution rules are that username in users.users becomes the username value username in home paths becomes home with username hostname in networking.hostName becomes the hostname value hostname in spring.application.name becomes the hostname value persist in environment.persistence reads from option and absolute paths for config and scripts are relative paths.

## Sprint Definitions

### Sprint 1

Foundation with the goal of creating the base system structure. It includes flake.nix as pure entry point with declarative inputs configuration.nix as auto scan module loader lib/default.nix exporting all libraries lib/hardware.nix as CPU GPU and Platform database src/modules/core for Boot Nix Locale and Sysctl src/hosts/hostname with meta default and hardware and AGENTS.md.

### Sprint 2

Filesystem and Immutability with the goal of implementing ZFS Impermanence and Disko. It includes the zfs module for pool ARC and snapshot the impermanence module for persist config desktop for external config files sanoid for automatic snapshot retention and disko for declarative partitioning.

### Sprint 3

Security with the goal of implementing extreme hardening firewall and SSH. It includes the firewall module with nftables default drop the external nftables configuration the hardening module for kernel and AppArmor the ssh module with keys only LAN only and audit logging with fail2ban.

### Sprint 4

Hardware Detection with the goal of auto configuring CPU GPU and Platform. It includes the cpu module for Intel AMD and ARM the gpu module for NVIDIA AMD and Intel the platform module for Desktop Laptop and Server and lib/hardware.nix as vendor optimization database.

### Sprint 5

Desktop and FlakeOS Layout with the goal of creating minimal KDE Plasma 6 with original FlakeOS layout. It includes the kde-minimal module for essential Plasma 6 the maclike module for the FlakeOS theme the pipewire module for audio the maclike scripts for init and finalize shell and the desktop config files for plasma-appletsrc kdeglobals and kwinrc.

### Sprint 6

Container Engine with the goal of creating the container engine with hardware level isolation. It includes the microvm-host module for host and bridge the orchestrator module for pool manager the sandbox guest as generic template the containers configuration for bridge and networking and SocketVM for desktop apps with X11 and Wayland forwarding.

### Sprint 7

Spring Framework with the goal of implementing Dependency Injection and Circuit Breaker. It includes lib/spring.nix for bean definitions topological sort mkSystemdService with resource limits circuit breaker with failure success and state circular dependency detection and the spring scripts for circuit-breaker and health. It also includes the orchestrator update to use Spring beans.

### Sprint 8

Instance Pool Orchestrator with the goal of creating the pool of isolated instances for any application. It includes the instance-pool module with pool options the guest definition per application the pool configuration the pool scripts for pool-manager spawn list and stats cgroup v2 for per instance resource isolation and Caddy reverse proxy for routing to instances.

### Sprint 9

Testing and Documentation with the goal of implementing pure Nix tests and complete documentation. It includes tests/default.nix for pure library tests tests/shell.nix for linting environment with statix and deadnix docs as user manual in text format AGENTS.md with always updated agentic rules and ISO generation for immediate deploy.

The sprint flow proceeds from Sprint 1 to Sprint 2 to Sprint 3 to Sprint 4 from which it branches to Sprint 5 which continues to Sprint 6 which leads to Sprint 7 and Sprint 8 and finally Sprint 9. Each sprint produces a working NixOS generation without unsatisfied dependencies. All sprints from number 1 to number 9 are completed.

## Spring Framework Specification

### Bean Definition

Bean definition happens via flakeos.spring.beans.name with attributes enable to enable class as service type deps as list of beans it depends on resources with cpu memory memoryMax pids ioRbps ioWbps and numa healthcheck as command to verify status dependsOn for systemd dependencies after for systemd ordering and restartPolicy for restart policy.

### Circuit Breaker

The Circuit Breaker state machine has three states. CLOSED is normal operation where requests pass through and failures increment a counter. OPEN is open circuit where requests are blocked and a timeout timer starts. HALF-OPEN is recovery test where limited requests are allowed. Transitions are that CLOSED transitions to OPEN when failures reach the threshold which defaults to 5. OPEN transitions to HALF-OPEN after the timeout which defaults to 30 seconds. HALF-OPEN transitions to CLOSED when successes reach the threshold which defaults to 2. HALF-OPEN transitions to OPEN when a failure occurs in half-open.

### Topological Sort

Topological sort resolves dependencies between beans at build time. If a cycle exists the build fails with an error message indicating circular dependency in the specified beans.

### Cgroup Hierarchy

The cgroup v2 hierarchy is organized under sys fs cgroup with the host name containing bean-database bean-redis and bean-webapp with cpu.max memory.max pids.max and io.max and OOM policy kill. The flakeos section contains pool for MicroVM instances with instance-001 and instance-002 with cpu.max at 50 percent and memory.max at 256 MB.

## Security Baseline

### Kernel Parameters

The kernel sysctl parameters include kernel.kptr_restrict set to 2 kernel.dmesg_restrict to 1 kernel.perf_event_paranoid to 3 kernel.yama.ptrace_scope to 2 kernel.randomize_va_space to 2 kernel.unprivileged_bpf_disabled to 1 net.core.bpf_jit_enable to 0 kernel.kexec_load_disabled to 1 and kernel.sysrq to 0.

### Firewall

The nftables firewall defines chain input with policy DROP accepting established and related connections loopback interface traffic ICMP with rate limit of 10 per second and TCP port 22 from LAN addresses and logging and dropping everything else. chain forward with policy DROP accepts established and related connections and traffic from the microvm interface. chain output with policy ACCEPT.

### SSH Hardening

SSH hardening provides PermitRootLogin no PasswordAuthentication no PubkeyAuthentication yes MaxAuthTries 3 MaxSessions 4 AllowTcpForwarding no AllowAgentForwarding no ciphers ChaCha20-Poly1305 and AES-256-GCM and MACs HMAC-SHA2-512-ETM and HMAC-SHA2-256-ETM. AppArmor is enforced with active cache profiles from apparmor-profiles and lockdown set to confidentiality.

## Quality Gates

The mandatory quality gates before each merge include statix check src for Nix linting deadnix src for dead code detection nixpkgs-fmt check src for formatting nix-instantiate --eval --strict tests/default.nix for library tests and nix-instantiate --eval --strict tests/modules.nix for module integration tests. The merge must be blocked if any of the quality gates fails.

## Templates

### Module Template

The template for a new module requires defining config lib pkgs using let cfg config.flakeos.category.module to access options. options.flakeos.category.module must contain enable as mkEnableOption and option1 as mkOption with type and default. config must be wrapped in mkIf cfg.enable with attr set to mkDefault cfg.option1.

### Host Template

The template for a new host requires a meta.nix file with system hardware profile hostname and username. The default.nix file receives config lib pkgs username and hostname and configures networking.hostName with hostname and users.users with username as isNormalUser true and extraGroups with wheel.

### Shell Script Template

The template for a shell script requires the file in scripts/category/name.sh with bash shebang set euo pipefail parameters with defaults and main function that executes the logic. The reference in Nix uses pkgs.writeShellScriptBin with builtins.readFile to read the script path.

## Idempotency and Atomicity

The idempotency rules require that nixos-rebuild switch is idempotent running it twice in a row must produce the same result. There must be no side effects outside the nix store. The etc directory is regenerated on every build. User state resides only in persist and home. The root filesystem is ephemeral via impermanence. Every nixos-rebuild produces a new generation. The previous generation remains intact in the boot menu. Rollback is performed with nixos-rebuild switch rollback. ZFS performs automatic pre rebuild snapshot and post rebuild snapshot via sanoid. Workarounds attempts hacks and placeholders have zero tolerance.

## Agent Workflow

When the user requests a modification the agent searches src/modules for the relevant module. If it does not exist it creates a new category creates default.nix and creates the module file. Then it modifies options and config. If shell scripts are needed they go in scripts never inline. If config files are needed they go in config never inline. If hardcoding exists it is replaced with options mkDefault and mkIf. If comments exist in Nix files they are removed and placed in AGENTS.md. Then it runs statix deadnix and nixpkgs-fmt. It verifies idempotency. Every modification must be submitted as a pull request on the alpha branch targeting main. Direct commits to main are forbidden. Merges are performed only when explicitly requested by the user. Merge commits use squash strategy with empty body and no pull request number in the title.

---

Copyright 2026 Distributed under MIT license
