#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_BUILD_DIR="$PROJECT_ROOT/.build/app"
INSTALL_PREFIX="${TAHOE_CC_PREFIX:-$HOME/.local}"
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
cmake -S "$PROJECT_ROOT/app" -B "$APP_BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
cmake --build "$APP_BUILD_DIR" --parallel
cmake --install "$APP_BUILD_DIR"
install -Dm644 "$PROJECT_ROOT/app/control-center-autostart.desktop" \
    "$AUTOSTART_DIR/tahoe-control-center.desktop"
kbuildsycoca6 --noincremental
