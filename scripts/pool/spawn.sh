#!/usr/bin/env bash
set -euo pipefail

POOL_DIR="${POOL_DIR:-/var/lib/instance-pool}"
BASE_PORT="${BASE_PORT:-8443}"
RUNNING=$(ls -d "${POOL_DIR}"/running/* 2>/dev/null | wc -l)
PORT="${1:-$((BASE_PORT + RUNNING + 1))}"
INST_ID="instance-manual-$$"

microvmctl start \
  --id "${INST_ID}" \
  --env "PORT=${PORT}"

mkdir -p "${POOL_DIR}/running/${INST_ID}"
printf "%s:%s\n" "${INST_ID}" "${PORT}" > "${POOL_DIR}/running/${INST_ID}/.metadata"
printf "%s\n" "${PORT}"
