#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${1:?STATE_DIR required}"
CGROUP_PARENT="${2:?CGROUP_PARENT required}"
MICROVM_DIR="${3:?MICROVM_DIR required}"
INTERVAL="${4:-30}"

mkdir -p "$STATE_DIR"
echo "+cpu +memory +io +pids" > /sys/fs/cgroup/cgroup.subtree_control 2>/dev/null || true
mkdir -p "${CGROUP_PARENT}" 2>/dev/null || true

while true; do
  for vm in "${MICROVM_DIR}"/*/; do
    [ -d "$vm" ] || continue
    vm_name=$(basename "$vm")
    echo "checking microvm $vm_name"
  done
  sleep "${INTERVAL}"
done
