#!/usr/bin/env bash
set -euo pipefail

export HOME="${HOME:-/home/user}"
export KDEHOME="${HOME}/.config"

kwriteconfig6 --file "${HOME}/.config/kdeglobals" --group "General" --key "ColorScheme" "BoraDark"
kwriteconfig6 --file "${HOME}/.config/kdeglobals" --group "General" --key "Name" "Bora"
kwriteconfig6 --file "${HOME}/.config/kdeglobals" --group "Icons" --key "Theme" "TelaCircleDark"
kwriteconfig6 --file "${HOME}/.config/plasmarc" --group "Theme" --key "name" "Breeze"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Compositing" --key "AnimationSpeed" "1"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Windows" --key "TitlebarDoubleClickCommand" "Maximize"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Windows" --key "BorderlessMaximizedWindows" "true"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Windows" --key "FocusPolicy" "ClickToFocus"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Desktops" --key "Number" "6"
kwriteconfig6 --file "${HOME}/.config/kwinrc" --group "Desktops" --key "Rows" "2"

plasma-apply-desktoptheme "Breeze" 2>/dev/null || true
plasma-apply-colorscheme "BoraDark" 2>/dev/null || true

kquitapp6 plasmashell 2>/dev/null || true
kstart6 plasmashell &>/dev/null &

kwin_x11 --replace &>/dev/null 2>&1 &
