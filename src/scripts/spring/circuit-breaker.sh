#!/usr/bin/env bash
set -euo pipefail

CB_DIR="${CB_DIR:?CB_DIR required}"
mkdir -p "${CB_DIR}"

BEAN="${1:?BEAN name required}"
THRESHOLD="${2:?THRESHOLD required}"
TIMEOUT_MS="${3:?TIMEOUT_MS required}"
SUCCESS_THRESHOLD="${4:?SUCCESS_THRESHOLD required}"
HALF_OPEN_MAX="${5:?HALF_OPEN_MAX required}"

STATE_FILE="${CB_DIR}/${BEAN}-state"
FAILURES_FILE="${CB_DIR}/${BEAN}-failures"
SUCCESSES_FILE="${CB_DIR}/${BEAN}-successes"
SINCE_FILE="${CB_DIR}/${BEAN}-since"

circuit_state() {
  if [ -f "${STATE_FILE}" ]; then
    cat "${STATE_FILE}"
  else
    echo "closed"
  fi
}

circuit_open() {
  echo "open" > "${STATE_FILE}"
  date +%s > "${SINCE_FILE}"
  echo 0 > "${FAILURES_FILE}"
}

circuit_half_open() {
  echo "half-open" > "${STATE_FILE}"
}

circuit_close() {
  echo "closed" > "${STATE_FILE}"
  echo 0 > "${FAILURES_FILE}"
  echo 0 > "${SUCCESSES_FILE}"
}

circuit_trip() {
  local state
  state=$(circuit_state)
  case "${state}" in
    closed)
      local failures=0
      [ -f "${FAILURES_FILE}" ] && failures=$(cat "${FAILURES_FILE}")
      failures=$((failures + 1))
      echo "${failures}" > "${FAILURES_FILE}"
      if [ "${failures}" -ge "${THRESHOLD}" ]; then
        circuit_open
        return 1
      fi
      ;;
    open)
      local since=0 now
      [ -f "${SINCE_FILE}" ] && since=$(cat "${SINCE_FILE}")
      now=$(date +%s)
      if [ "$((now - since))" -ge "$((TIMEOUT_MS / 1000))" ]; then
        circuit_half_open
      fi
      return 1
      ;;
    half-open)
      local failures=0
      [ -f "${FAILURES_FILE}" ] && failures=$(cat "${FAILURES_FILE}")
      if [ "${failures}" -lt "${HALF_OPEN_MAX}" ]; then
        failures=$((failures + 1))
        echo "${failures}" > "${FAILURES_FILE}"
        circuit_open
        return 1
      else
        circuit_close
        return 0
      fi
      ;;
  esac
}

circuit_success() {
  local state
  state=$(circuit_state)
  if [ "${state}" = "half-open" ]; then
    local successes=0
    [ -f "${SUCCESSES_FILE}" ] && successes=$(cat "${SUCCESSES_FILE}")
    successes=$((successes + 1))
    echo "${successes}" > "${SUCCESSES_FILE}"
    if [ "${successes}" -ge "${SUCCESS_THRESHOLD}" ]; then
      circuit_close
    fi
  else
    echo 0 > "${FAILURES_FILE}"
  fi
}

case "${6:?ACTION required (trip|success|status)}" in
  trip)
    circuit_trip
    exit $?
    ;;
  success)
    circuit_success
    exit 0
    ;;
  status)
    circuit_state
    exit 0
    ;;
  *)
    echo "Usage: circuit-breaker.sh <bean> <threshold> <timeout_ms> <success_thr> <halfopen_max> <trip|success|status>"
    exit 1
    ;;
esac