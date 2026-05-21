#!/usr/bin/env bash
set -euo pipefail

APP="${1:?APP name required}"
CGROUP_PARENT="${2:?CGROUP_PARENT required}"

printf "=== Resource usage: %s ===\n" "${APP}"
for cg in ${CGROUP_PARENT}/${APP}/*; do
  [ -d "${cg}" ] || continue
  name="${cg##*/}"
  mem=$(cat "${cg}/memory.current" 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "N/A")
  cpu=$(cat "${cg}/cpu.stat" 2>/dev/null | grep usage_usec | cut -d' ' -f2 || echo "N/A")
  pids=$(cat "${cg}/pids.current" 2>/dev/null || echo "N/A")
  printf "  %-25s mem=%-10s cpu=%-10s pids=%s\n" "${name}" "${mem}" "${cpu}" "${pids}"
done
