#!/usr/bin/env bash
set -euo pipefail

APP="${1:?APP name required}"

printf "=== Spring Application: %s ===\n" "${APP}"
printf "Active beans:\n"
systemctl list-units "spring-${APP}-*" --no-legend | \
  while read -r unit _ _ active _; do
    printf "  %-55s %s\n" "${unit}" "${active}"
  done

printf "\nCircuit breaker states:\n"
for f in /run/flakeos-cb/*-state; do
  [ -f "${f}" ] || continue
  name="${f%-state}"
  name="${name##*/}"
  state=$(cat "${f}")
  printf "  %-40s %s\n" "${name}" "${state}"
done
