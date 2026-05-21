#!/usr/bin/env bash
set -euo pipefail

CG_DIR="${1:?CG_DIR required}"
MEM="${2:-256M}"
CPU="${3:-0.5}"
PIDS="${4:-512}"
STORAGE="${5:-2G}"
IO_DEVICE="${6:-8:0}"

mkdir -p "${CG_DIR}"
echo "${MEM}" > "${CG_DIR}/memory.max"
echo "${MEM}" > "${CG_DIR}/memory.high"
echo "${CPU}0000" > "${CG_DIR}/cpu.max"
echo "${PIDS}" > "${CG_DIR}/pids.max"
echo "${IO_DEVICE}  ${STORAGE}" > "${CG_DIR}/io.max"
