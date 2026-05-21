#!/usr/bin/env bash
set -euo pipefail

BEAN="${1:?BEAN required}"
EXEC="${2:?EXEC required}"
shift 2

CB="/run/current-system/sw/bin/circuit-breaker"
HC="/run/current-system/sw/bin/healthcheck"

if ! "${CB}" "${BEAN}" 5 30000 2 3 status; then
  exit 1
fi

if ! "${EXEC}" "$@"; then
  "${CB}" "${BEAN}" 5 30000 2 3 trip
  exit 1
fi

"${CB}" "${BEAN}" 5 30000 2 3 success
