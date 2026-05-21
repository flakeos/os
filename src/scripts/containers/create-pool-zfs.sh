#!/usr/bin/env bash
set -euo pipefail

POOL="${1:?POOL name required}"
MOUNTPOINT="${2:?MOUNTPOINT required}"
QUOTA="${3:?QUOTA required}"

zfs create -o mountpoint="${MOUNTPOINT}" \
  -o atime=off -o compression=zstd-3 \
  -o quota="${QUOTA}" \
  "${POOL}/instance-pool" 2>/dev/null || true
