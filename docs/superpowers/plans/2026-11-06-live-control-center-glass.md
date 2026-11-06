# Live Control Center Glass Implementation Plan

> **For agentic workers:** Execute this plan inline in small, reversible checkpoints. Do not restart Plasma or alter the user's active windows.

**Goal:** Run the existing Tahoe Control Center with the Acrylic Glass KWin effect applied only to its own window, using the live composited content underneath each card.

**Architecture:** Keep the standalone Qt/QML tray application as the UI and keep `useLiquidGlass: false` so it never samples or paints a cached wallpaper. Use the installed KWin effect's per-window class filter and the existing per-card blur mask for live blur/refraction. Update only the stale user-local app binary and leave the effect configuration scoped to `tahoe-control-center`.

**Tech Stack:** Qt 6.6+, Qt Quick, KF6, KWin 6, X11, NetworkManager, BlueZ, PulseAudio/PipeWire controls.

## Global Constraints

- Preserve all current untracked comparison images and working-tree changes.
- Do not restart `plasmashell`, KWin, or the active session.
- Keep app-side wallpaper shader disabled; use the compositor's current scene for refraction.
- Do not enable the effect for ordinary applications; keep the existing `tahoe-control-center` class allow-list.
- Preserve the existing blur/refraction calibration; do not run broad parameter sweeps.
- Keep Wi-Fi/brightness unavailable where Rebecca lacks corresponding hardware; Bluetooth/audio may use detected devices.
- Do not create a PR.

---

### Task 1: Rebuild and refresh the tray application

**Files:**
- Build `app/CMakeLists.txt`, `app/Main.qml`, `app/SystemControlController.cpp`, `app/TrayController.cpp`.
- Install to the existing `~/.local/bin/tahoe-control-center` entry point.

- [x] Build with `./build-app.sh` and confirm `.build/app/tahoe-control-center` is newer than the installed executable.
- [x] Run the existing package checks with `python3 -m pytest -q tests/test_package.py`.
- [x] Stop only the hidden Tahoe Control Center process, replace its user-local executable via `./install-app.sh`, and relaunch it hidden in the tray. No Plasma process was touched.
- [x] Confirm the installed binary hash matches `.build/app/tahoe-control-center`.

### Task 2: Enable and verify app-scoped live glass

**Files:**
- Runtime configuration: `~/.config/kwinrc`, group `[Plugins]` and `[Effect-liquidglass]`.
- Effect implementation: `../macos-tahoe-liquid-kde/src/offline/kwin-effects/acrylic-glass/src/effect.cpp`.
- App window class: `app/main.cpp` and `app/Main.qml`.

- [x] Back up the existing `kwinrc` before changing only `Plugins/liquidglassEnabled` to true; retain `WindowClasses=tahoe-control-center`, `BlurMatching=true`, `BlurNonMatching=false`, and `RefractionWidth=56`.
- [x] Load `liquidglass` through KWin's Effects D-Bus API without restarting KWin; confirm `isEffectLoaded liquidglass` returns true.
- [x] Confirm the Control Center window reports `WM_CLASS=tahoe-control-center` and matches the class filter.
- [x] Open one short preview, confirm real application content is present beneath the glass, close the popup, and save a screenshot. Motion-by-motion refraction remains unbenchmarked.
- [ ] If the effect causes instability, unload it immediately and restore the previous `Plugins/liquidglassEnabled` value from the saved backup.

### Task 3: Record the working result

**Files:** `docs/macos-tahoe-reference-map.md`, `docs/live-glass-validation.md`.

- [x] Record the installed build hash, KWin loaded state, class filter, hardware availability and screenshot path in `docs/live-glass-validation.md`.
- [x] Record Wi-Fi and brightness as unavailable on this host; Bluetooth and audio controls are available.
