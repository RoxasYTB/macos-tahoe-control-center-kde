#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
APP_BUILD_DIR="$PROJECT_ROOT/.build/app"
cmake -S "$PROJECT_ROOT/app" -B "$APP_BUILD_DIR" -DCMAKE_BUILD_TYPE=Release
cmake --build "$APP_BUILD_DIR" --parallel
