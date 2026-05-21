#!/usr/bin/env bash
set -euo pipefail

zfs snapshot "@POOL@/@DATASET@-pre-rebuild-$(date +%Y%m%d-%H%M%S)"
