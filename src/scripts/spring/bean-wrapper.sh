#!/usr/bin/env bash
set -euo pipefail

BEAN="${1:?BEAN required}"
EXEC="${2:?EXEC required}"
shift 2

CB="${CB_BIN:?CB_BIN required}"
HC="${HC_BIN:?HC_BIN required}"
THRESHOLD="${CB_THRESHOLD:?CB_THRESHOLD required}"
TIMEOUT_MS="${CB_TIMEOUT:?CB_TIMEOUT required}"
SUCCESS_THR="${CB_SUCCESS_THRESHOLD:?CB_SUCCESS_THRESHOLD required}"
HALF_OPEN_MAX="${CB_HALF_OPEN_MAX:?CB_HALF_OPEN_MAX required}"

if ! "${CB}" "${BEAN}" "${THRESHOLD}" "${TIMEOUT_MS}" "${SUCCESS_THR}" "${HALF_OPEN_MAX}" status; then
  exit 1
fi

if ! "${EXEC}" "$@"; then
  "${CB}" "${BEAN}" "${THRESHOLD}" "${TIMEOUT_MS}" "${SUCCESS_THR}" "${HALF_OPEN_MAX}" trip
  exit 1
fi

"${CB}" "${BEAN}" "${THRESHOLD}" "${TIMEOUT_MS}" "${SUCCESS_THR}" "${HALF_OPEN_MAX}" success