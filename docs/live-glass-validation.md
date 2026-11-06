# Live Liquid Glass validation on Rebecca

Date: 2026-11-06

## Runtime result

- Plasma 6.7.4, X11; KWin reports the `liquidglass` effect supported.
- Enabled `Plugins/liquidglassEnabled` and loaded the effect through KWin's Effects D-Bus API without restarting KWin or Plasma.
- The live filter is `WindowClasses=tahoe-control-center`, `BlurMatching=true`, `BlurNonMatching=false`; `RefractionWidth=56` is preserved. Other application windows remain outside the effect's match list.
- The Control Center window reports `WM_CLASS=tahoe-control-center`, matching that filter.
- The app-side `useLiquidGlass` stays false so QML does not draw a second wallpaper-sampling shader. The visible glass comes from KWin sampling the composited scene behind the popup.
- Opened the updated app once, captured the glass over the actual ChatGPT window, then closed the preview and left the tray app running hidden.

Capture: `/tmp/tahoe-control-center-live-glass-preview-20261106.png` (full 5760x1227 desktop) and `/tmp/tahoe-control-center-live-glass-popup-20261106.png` (304x496 Control Center crop).

## Installed build and checks

- `./build-app.sh`: passed.
- `python3 -m pytest -q tests/test_package.py`: 6 passed.
- Installed binary SHA-256: `8b98845e85616533faf678da304f6347ca609cd8daec449b4713d6e116ad88f2` (matches `.build/app/tahoe-control-center`).
- The generated user autostart unit `app-tahoe\x2dcontrol\x2dcenter@autostart.service` is active and runs exactly one hidden tray process after the visual capture.
- `kwinrc` backup before enabling the plugin: `/tmp/kwinrc-before-tahoe-glass-20261106-163125`.

## Host capability limits

- Wi-Fi shows unavailable: Rebecca currently has Ethernet interfaces only.
- Display brightness shows unavailable: no backlight device is exposed under `/sys/class/backlight`.
- Bluetooth and sound controls are present; the capture shows Bluetooth on and the default audio control.

This confirms the effect is active on the matching app window and shows live application content beneath the cards. It is not a full motion/refraction benchmark. No broad glass-parameter tuning or Plasma restart was performed.
