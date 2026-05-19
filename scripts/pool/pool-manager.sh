#!/usr/bin/env bash
set -euo pipefail

POOL_DIR="${POOL_DIR:-/var/lib/instance-pool}"
BASE_PORT="${BASE_PORT:-8443}"
MAX="${MAX_INSTANCES:-899}"
MEM="${MEM_LIMIT:-256M}"
CPU="${CPU_LIMIT:-0.5}"
APP="${APP_COMMAND:-}"
HC="${HEALTHCHECK_CMD:-curl -sf http://localhost:${PORT}/health}"

mkdir -p "${POOL_DIR}"/{running,logs}
mkdir -p /sys/fs/cgroup/bora/pool

cleanup() {
  for dir in "${POOL_DIR}"/running/*; do
    [ -d "${dir}" ] || continue
    inst=$(basename "${dir}")
    microvmctl stop "${inst}" 2>/dev/null || true
  done
  exit 0
}
trap cleanup EXIT INT TERM

while true; do
  RUNNING=$(ls -d "${POOL_DIR}"/running/* 2>/dev/null | wc -l)

  if [ "${RUNNING}" -lt "${MAX}" ]; then
    NEED=$((MAX - RUNNING))
    for i in $(seq 1 "${NEED}"); do
      INST_ID="instance-$(date +%s)-${RANDOM}"
      PORT=$((BASE_PORT + RUNNING + i))
      INST_DIR="${POOL_DIR}/running/${INST_ID}"
      mkdir -p "${INST_DIR}"

      microvmctl start \
        --id "${INST_ID}" \
        --env "PORT=${PORT}" \
        --mem "${MEM}" \
        --cpu "${CPU}" &

      printf "%s:%s\n" "${INST_ID}" "${PORT}" > "${INST_DIR}/.metadata"
    done
    wait
  fi

  for metafile in "${POOL_DIR}"/running/*/.metadata; do
    [ -f "${metafile}" ] || continue
    INST_DIR="${metafile%/*}"
    INST_ID=$(basename "${INST_DIR}")
    PORT=$(cut -d: -f2 < "${metafile}")
    HC_CMD="${HC//\$\{PORT\}/${PORT}}"
    if ! eval "${HC_CMD}" >/dev/null 2>&1; then
      microvmctl stop "${INST_ID}" 2>/dev/null || true
      rm -rf "${INST_DIR}"
    fi
  done

  sleep 10
done
