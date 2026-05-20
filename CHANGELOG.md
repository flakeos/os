# Changelog

## 25.11 (2026-05-20)

- fix: simplify CI, fix desktop ISO, fix vaapiVdpau rename
- fix: remove invalid iso-minimal-validation alias from flake.nix
- fix: rename iso-graphical to iso-desktop, add iso-laptop, restructure CI with isolated test+benchmark, fix vaapiVdpau rename
- fix: repair YAML syntax in ci.yml (duplicated job fields) and restore ISO build steps
- feat: add iso-server, 3 ISO CI builds, rewrite tests with concrete cases and benchmarks
- fix: remove `.github` from paths-ignore so CI runs on workflow changes
- fix: remove build-system job (host-specific hw), simplify CI, fix nvidia portal
- fix: remove xdg-desktop-portal-kde reference no longer in nixpkgs 25.11
- fix: use `systemd.settings.Manager` and `kdePackages.xdg-desktop-portal-kde` for nixos 25.11 compat
- fix: wrap inline module functions in parentheses
- fix: add lib to inline module args in flake.nix
- fix: resolve platform/gpu prime conflict, use `image.baseName` for ISO, simplify CI
- fix: update KDE ISO module path and remove conflicting hardware defaults from workstation profile
- fix: consolidate etc attrs in maclike.nix to resolve W20
- fix: resolve remaining statix W04 and W20 warnings
- feat: update stateVersion to 25.11, add CI build and test jobs, add gitignore
- fix: resolve statix warnings and disable FlakeHub cache in CI
- fix: resolve devShell buildInputs type error in CI
- feat: add CI workflows, build script, docs and fix nftables ZFS boot

## 25.05 (2026-04-15)

- feat: add test suite infrastructure
- feat: add shell scripts for spring, pool and desktop
- feat: add containers, microvm guests and instance pool
- feat: add desktop, network and config file modules
- feat: implement security, hardware and filesystem modules
- feat: add hosts, profiles and core modules
- feat: add foundation layer with flake, config, lib and docs
