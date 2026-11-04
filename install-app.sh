#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_BUILD_DIR="$PROJECT_ROOT/.build/app"
INSTALL_PREFIX="${TAHOE_CC_PREFIX:-$HOME/.local}"
AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
cmake -S "$PROJECT_ROOT/app" -B "$APP_BUILD_DIR" \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"
nice -n 10 cmake --build "$APP_BUILD_DIR" --parallel 1
cmake --install "$APP_BUILD_DIR"

install_desktop_entry() {
    local template="$1"
    local destination="$2"
    local temporary
    temporary="$(mktemp)"

    # systemd's XDG autostart generator does not search ~/.local/bin in PATH.
    # Resolve the executable when installing so login autostart and launchers
    # consistently start this user-local build.
    python3 - "$template" "$temporary" "$INSTALL_PREFIX/bin/tahoe-control-center" <<'PY'
from pathlib import Path
import os
import sys

source, output, executable = map(Path, sys.argv[1:])
exec_value = '"' + str(executable).replace("\\", "\\\\").replace('"', '\\"') + '"'
lines = source.read_text(encoding="utf-8").splitlines()
updated = [f"Exec={exec_value}" if line.startswith("Exec=") else line for line in lines]
Path(output).write_text("\n".join(updated) + "\n", encoding="utf-8")
os.chmod(output, 0o644)
PY
    install -Dm644 "$temporary" "$destination"
    rm -f "$temporary"
}

install_desktop_entry "$PROJECT_ROOT/app/control-center.desktop" \
    "$INSTALL_PREFIX/share/applications/control-center.desktop"
install_desktop_entry "$PROJECT_ROOT/app/control-center-autostart.desktop" \
    "$AUTOSTART_DIR/tahoe-control-center.desktop"
kbuildsycoca6 --noincremental
