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
- Installed binary SHA-256: `f80f31658926b7a93cf1d0b73cd9c7c492c16eaa521a920583806f225e7c4eb0` (matches `.build/app/tahoe-control-center`).
- The generated user autostart unit `app-tahoe\x2dcontrol\x2dcenter@autostart.service` is active and runs exactly one hidden tray process after the visual capture.
- `kwinrc` backup before enabling the plugin: `/tmp/kwinrc-before-tahoe-glass-20261106-163125`.

## Host capability limits

- Wi-Fi shows unavailable: Rebecca currently has Ethernet interfaces only.
- Display brightness shows unavailable: no backlight device is exposed under `/sys/class/backlight`.
- Bluetooth and sound controls are present; the capture shows Bluetooth on and the default audio control.

This confirms the effect is active on the matching app window and shows live application content beneath the cards. It is not a full motion/refraction benchmark. No broad glass-parameter tuning or Plasma restart was performed.

## 2026-11-07 detail popup and default layout correction

- The Wi-Fi and Bluetooth detail views now use `Popup.Item`, staying inside the main `tahoe-control-center` window. This is required for the KWin class-scoped Liquid Glass effect and the selected detail blur mask to apply to those views.
- The host window now follows the active detail view height, including an expanded Wi-Fi network list. The detail views fit the host width rather than extending past its left edge.
- The saved control list omitted `Now Playing`, which previously made the entire panel fall back to a generic flow layout. A missing standard tile now preserves the reference grid; reordering or adding non-standard items still selects custom layout. The local reference configuration has `Now Playing` restored so its media card is shown.
- Live capture after the correction: `/tmp/tahoe-cc-main-reference-20261107.png` and `/tmp/tahoe-cc-wifi-reference-20261107.png`. The Wi-Fi view remained a single X11 window (`WM_CLASS=tahoe-control-center`) and resized to 304x176, with no second popup window. The screenshots were taken over live YouTube content; no desktop-wide or KWin restart was needed.
- On the selected 1920x1080 display, X11 reported the main panel window at `(1615, 183)` while that display begins at `(0, 142)`: relative placement is `(1615, 41)`. The panel content is 292 px wide, leaving a 13 px right inset, matching the supplied reference. Its 304x496 host includes the intended transparent margins.
- Verification: `python3 -m pytest -q tests/test_package.py` (7 passed), `./build-app.sh`, `./install-app.sh`, installed/build SHA-256 match, and the user autostart service is active. The KWin effect remains enabled only for the Control Center class.
- Wi-Fi and brightness remain unavailable on this machine (Ethernet-only network interfaces and no `/sys/class/backlight`). Bluetooth and sound remain connected to live system controls. AirDrop and Focus remain visibly disabled as previously requested.
