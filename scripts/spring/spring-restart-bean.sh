#!/usr/bin/env bash
set -euo pipefail

APP="${1:?APP required}"
BEAN="${2:?BEAN required}"

systemctl restart "spring-${APP}-${BEAN}.service"
