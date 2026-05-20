#!/usr/bin/env bash
set -euo pipefail

sleep 2

lookandfeeltool -a "org.kde.breezedark.desktop" 2>/dev/null || true

qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true