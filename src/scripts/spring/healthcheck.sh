#!/usr/bin/env bash
set -euo pipefail

BEAN="${1:?BEAN required}"
COMMAND="${2:?HEALTHCHECK COMMAND required}"
INTERVAL="${3:-10}"
MAX_RETRIES="${4:-3}"
RETRY_DELAY="${5:-2}"
CB_SCRIPT="${CB_BIN:-${6:-/run/current-system/sw/bin/circuit-breaker}}"
THRESHOLD="${CB_THRESHOLD:-5}"
TIMEOUT_MS="${CB_TIMEOUT:-30000}"
SUCCESS_THR="${CB_SUCCESS_THRESHOLD:-2}"
HALF_OPEN_MAX="${CB_HALF_OPEN_MAX:-3}"

run_check() {
  if eval "${COMMAND}" >/dev/null 2>&1; then
    "${CB_SCRIPT}" "${BEAN}" "${THRESHOLD}" "${TIMEOUT_MS}" "${SUCCESS_THR}" "${HALF_OPEN_MAX}" success
    return 0
  else
    return 1
  fi
}

retry=0
while [ "${retry}" -lt "${MAX_RETRIES}" ]; do
  if run_check; then
    exit 0
  fi
  retry=$((retry + 1))
  [ "${retry}" -lt "${MAX_RETRIES}" ] && sleep "${RETRY_DELAY}"
done

"${CB_SCRIPT}" "${BEAN}" "${THRESHOLD}" "${TIMEOUT_MS}" "${SUCCESS_THR}" "${HALF_OPEN_MAX}" trip
exit 1
