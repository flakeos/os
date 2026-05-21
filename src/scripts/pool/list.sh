#!/usr/bin/env bash
set -euo pipefail

POOL_DIR="${POOL_DIR:?POOL_DIR required}"

for dir in "${POOL_DIR}"/running/*; do
  [ -d "${dir}" ] || continue
  INST_ID=$(basename "${dir}")
  if [ -f "${dir}/.metadata" ]; then
    PORT=$(cut -d: -f2 < "${dir}/.metadata")
    printf "%s:%s\n" "${INST_ID}" "${PORT}"
  fi
done
