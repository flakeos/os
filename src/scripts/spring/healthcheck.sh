#!/usr/bin/env bash
set -euo pipefail

BEAN="${1:?BEAN required}"
COMMAND="${2:?HEALTHCHECK COMMAND required}"
INTERVAL="${3:?INTERVAL required}"
MAX_RETRIES="${4:?MAX_RETRIES required}"
RETRY_DELAY="${5:?RETRY_DELAY required}"
CB_SCRIPT="${CB_BIN:?CB_BIN required}"
THRESHOLD="${CB_THRESHOLD:?CB_THRESHOLD required}"
TIMEOUT_MS="${CB_TIMEOUT:?CB_TIMEOUT required}"
SUCCESS_THR="${CB_SUCCESS_THRESHOLD:?CB_SUCCESS_THRESHOLD required}"
HALF_OPEN_MAX="${CB_HALF_OPEN_MAX:?CB_HALF_OPEN_MAX required}"

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