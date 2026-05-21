#!/usr/bin/env bash
set -euo pipefail

BEAN="${1:?BEAN required}"
EXEC="${2:?EXEC required}"
shift 2

CB="${CB_BIN:-/run/current-system/sw/bin/circuit-breaker}"
HC="${HC_BIN:-/run/current-system/sw/bin/healthcheck}"
THRESHOLD="${CB_THRESHOLD:-5}"
TIMEOUT_MS="${CB_TIMEOUT:-30000}"
SUCCESS_THR="${CB_SUCCESS_THRESHOLD:-2}"
HALF_OPEN_MAX="${CB_HALF_OPEN_MAX:-3}"

if ! "${CB}" "${BEAN}" "${THRESHOLD}" "${TIMEOUT_MS}" "${SUCCESS_THR}" "${HALF_OPEN_MAX}" status; then
  exit 1
fi

if ! "${EXEC}" "$@"; then
  "${CB}" "${BEAN}" "${THRESHOLD}" "${TIMEOUT_MS}" "${SUCCESS_THR}" "${HALF_OPEN_MAX}" trip
  exit 1
fi

"${CB}" "${BEAN}" "${THRESHOLD}" "${TIMEOUT_MS}" "${SUCCESS_THR}" "${HALF_OPEN_MAX}" success
