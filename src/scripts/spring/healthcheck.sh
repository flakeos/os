#!/usr/bin/env bash
set -euo pipefail

BEAN="${1:?BEAN required}"
COMMAND="${2:?HEALTHCHECK COMMAND required}"
INTERVAL="${3:-10}"
MAX_RETRIES="${4:-3}"
RETRY_DELAY="${5:-2}"
CB_SCRIPT="${6:-/run/current-system/sw/bin/circuit-breaker}"

run_check() {
  if eval "${COMMAND}" >/dev/null 2>&1; then
    "${CB_SCRIPT}" "${BEAN}" 5 30000 2 3 success
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

"${CB_SCRIPT}" "${BEAN}" 5 30000 2 3 trip
exit 1
