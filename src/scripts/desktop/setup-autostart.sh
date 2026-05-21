#!/usr/bin/env bash
set -euo pipefail

INIT_BIN="${1:?INIT_BIN required}"
mkdir -p /etc/skel/.config/autostart
cat > /etc/skel/.config/autostart/flakeos-desktop-setup.desktop << EOF
[Desktop Entry]
Type=Application
Name=FlakeOS Desktop Initializer
Exec=${INIT_BIN}
X-KDE-autostart-phase=2
OnlyShowIn=KDE
EOF
