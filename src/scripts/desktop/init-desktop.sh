#!/usr/bin/env bash
set -euo pipefail

kquitapp6 plasmashell 2>/dev/null || true
kstart6 plasmashell &>/dev/null &