#!/usr/bin/env bash
set -euo pipefail

export HOME="${HOME:-/home/user}"

sleep 2

lookandfeeltool -a "org.kde.breezedark.desktop" 2>/dev/null || true

kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Windows" --key "FocusPolicy" "ClickToFocus"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Compositing" --key "OpenGLIsUnsafe" "false"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Compositing" --key "AnimationSpeed" "1"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Desktops" --key "Number" "6"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Desktops" --key "Rows" "2"

qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
