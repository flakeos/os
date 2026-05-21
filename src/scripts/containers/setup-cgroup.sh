#!/usr/bin/env bash
set -euo pipefail

CG_DIR="${1:?CG_DIR required}"
MEM="${2:?MEM required}"
CPU="${3:?CPU required}"
PIDS="${4:?PIDS required}"
STORAGE="${5:?STORAGE required}"
IO_DEVICE="${6:?IO_DEVICE required}"

mkdir -p "${CG_DIR}"
echo "${MEM}" > "${CG_DIR}/memory.max"
echo "${MEM}" > "${CG_DIR}/memory.high"
echo "${CPU}0000" > "${CG_DIR}/cpu.max"
echo "${PIDS}" > "${CG_DIR}/pids.max"
echo "${IO_DEVICE}  ${STORAGE}" > "${CG_DIR}/io.max"
