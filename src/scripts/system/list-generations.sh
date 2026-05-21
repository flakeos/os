#!/usr/bin/env bash
set -euo pipefail

nix-env --list-generations -p /nix/var/nix/profiles/system
