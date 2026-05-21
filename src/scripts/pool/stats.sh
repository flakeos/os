#!/usr/bin/env bash
set -euo pipefail

POOL_DIR="${POOL_DIR:?POOL_DIR required}"
MAX="${MAX_INSTANCES:?MAX_INSTANCES required}"

RUNNING=$(ls -d "${POOL_DIR}"/running/* 2>/dev/null | wc -l)

printf "=== Pool Stats ===\n"
printf "Running: %s / %s\n" "${RUNNING}" "${MAX}"

for dir in "${POOL_DIR}"/running/*; do
  [ -d "${dir}" ] || continue
  INST_ID=$(basename "${dir}")
  PORT=$(cut -d: -f2 < "${dir}/.metadata" 2>/dev/null || true)
  MEM=$(cat /sys/fs/cgroup/flakeos/pool/"${INST_ID}"/memory.current 2>/dev/null | numfmt --to=iec 2>/dev/null || echo "N/A")
  printf "  %-35s port=%-6s mem=%s\n" "${INST_ID}" "${PORT}" "${MEM}"
done
