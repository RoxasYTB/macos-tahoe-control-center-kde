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

## 2026-11-07 live refraction recovery audit

The validated live capsule calibration is already restored in `[Effect-liquidglass]` in `~/.config/kwinrc`; it was not swept or guessed during this pass:

| Setting | Active value | Purpose |
| --- | ---: | --- |
| `BlurStrength` | `4.0` | Light compositor blur |
| `RefractionWidth` | `56` | Capsule lens width |
| `MagnifyGlassStrength` | `0.15` | Refraction strength |
| `RgbDriftStrength` | `0.0` | Disable the unwanted RGB fringe |
| `MaterialOpacity` | `1.0` | Preserve the tuned material |
| `WindowClasses` | `tahoe-control-center` | Restrict the effect to this app |
| `BlurMatching` / `BlurNonMatching` | `true` / `false` | Blur only matching windows |

The matching source is in the theme repository's `a8ad739` capsule calibration and its follow-up client-mask path: the per-card lens applies 55% of the configured magnification strength and scales RGB drift to 20%. With the active values above, the effective capsule strength is `0.0825` and RGB drift remains zero. The running KWin plugin is the installed `liquidglass.so` at SHA-256 `9a8f2f1827ffc3006fe7ff3d4e964a2d935a24ba2359c874abd7af23eca9c87c`, matching the already-built X11 plugin artifact; no KWin reload or restart was used.

Evidence captured on 2026-11-07:

- `/tmp/tahoe-liquidglass-on-20261107.png`, `/tmp/tahoe-liquidglass-off-20261107.png`, and `/tmp/tahoe-liquidglass-restored-20261107.png` compare the same Control Center with the effect enabled, briefly toggled off, and restored. `liquidglass` is active and loaded after the comparison. The saved `.kwinrc` values were unchanged.
- `/tmp/tahoe-liquidglass-live-source-compare-20261107.png` compares two captures 0.9 seconds apart over a normal composited test window with changing, high-contrast checker patterns. The mapped Control Center window remained at `(3535,41)`, size `304x496`, class `tahoe-control-center`; its card-region mean RGB frame delta was `(49.34, 48.17, 64.64)`, while the exposed source window changed by `(72.30, 72.37, 98.94)`. The cyan/pink and green/blue panels visibly update through the glass; this is live window content, not a wallpaper capture. The QML wallpaper-sampling path remains disabled in `app/Main.qml`.
- The user autostart service was restarted after the short probe and is active. The temporary probe window and preview process were closed. The KWin/Plasma session remained running throughout.

This confirms that the compositor effect is active and reacts to live scene content. It does **not** establish that the capsule's optical displacement is visibly convincing. The two-frame checker comparison primarily demonstrated that the backdrop was live; it did not separate refraction from blur. RGB dispersion remains intentionally disabled.

## 2026-11-07 correction: capsule refraction deployment

The earlier conclusion overstated what the two-frame comparison proved. That test confirmed a live composited backdrop, but did not by itself distinguish refraction from blur. The original `0.0825` effective-strength calculation also mixed the KWin setting with a QML-side calibration even though `app/Main.qml` disables that wallpaper-sampling shader. KWin passes global `MagnifyGlassStrength` to its shader, which then attenuates the lens for surfaces below 128 px.

The theme repository now applies a smooth, bounded boost to the lens only on small capsules. Its isolated OpenGL pixel test passes the no-fold checks at popup sizes through 64×48. The X11 plugin was rebuilt and installed under SHA-256 `0f480372b9aeb25b03ad8fefe5df09b420be2c7b458e6f04ded35366512ed705`, then reloaded without restarting KWin. KWin reports build identity `fcad0da6d8073039053f07877900b2506faba5847935a0b783840aedce45a696` active.

The accepted runtime values were `BlurStrength=4.0`, `MagnifyGlassStrength=0.15`, `RefractionWidth=56`, `RgbDriftStrength=0.0`, and `WindowClasses=tahoe-control-center`. The panel was opened on the **central HDMI display**, independent of the mouse position, over a composited straight-edge test window; the resulting crop is `/tmp/tahoe-liquidglass-refraction-middle-panel-20261107.png`. Plasma was restarted after deployment and is active; the Control Center autostart service is active. KWin itself was not restarted.

The user asked to restore the previously tuned values after a brief comparison at `BlurStrength=1.5` and `MagnifyGlassStrength=0.25`. Current KWin configuration has been returned to `BlurStrength=4.0`, `MagnifyGlassStrength=0.15`, `RefractionWidth=56`, and `RgbDriftStrength=0.0`; `liquidglass` reports loaded. The screenshot `/tmp/tahoe-refraction-blur15-center-monitor-20261107.png` is from the brief comparison and must not be treated as the restored reference.


## 2026-11-07 Control Center blur-mask alignment

The user's close-up showed the blur region sitting above the visible capsules. The root cause was stale fixed coordinates in `app/generate-blur-region-mask.py`, not a global KWin blur offset. Compared with `ControlCenterPanel.qml`, the old mask was 2 px high for Bluetooth and AirDrop, 1-2 px high for the circular/Focus row, 3 px high for Display, 5 px high for Sound, and 7 px high for Edit Controls. Updated each mask footprint to the QML coordinates and regenerated `app/control-center-blur-window-region.png`.

`./install-app.sh` rebuilt and installed the app successfully. Installed and build executable SHA-256 both equal `51b3c5649d76f47ea56d50dbfdd1b48b9d926113bff09998edd3c70cd76bce63`. The prior autostart instance and all preview processes were stopped; the status notifier list contained no Control Center item. A single preview from this build was captured on the center HDMI display, then closed; the current autostart service was started from the same installed build.

Visual evidence at the restored reference settings (`BlurStrength=4.0`, `MagnifyGlassStrength=0.15`, `RefractionWidth=56`, `RgbDriftStrength=0.0`): `/tmp/tahoe-final-mask-aligned-center-monitor-20261107.png` (center display only), `/tmp/tahoe-final-mask-aligned-panel-20261107.png` (panel crop), and `/tmp/tahoe-blur-mask-before-after-sound-20261107.png` (user close-up beside aligned result). The preview window geometry was `(3535,41)`, size `304x496`, on HDMI-0 at `(1920,0)`; the mouse was restored after capture.


A valid visual strength batch was then captured with the panel visible and confirmed in `wmctrl` before and after each frame. The display was always cropped to the physical center HDMI output `(1920,0)`, not selected from the mouse display. The four panel crops and labeled matrix are `/tmp/tahoe-maskfix-strength-0.10-batch-panel-20261107.png`, `/tmp/tahoe-maskfix-strength-0.15-batch-panel-20261107.png`, `/tmp/tahoe-maskfix-strength-0.20-batch-panel-20261107.png`, `/tmp/tahoe-maskfix-strength-0.25-batch-panel-20261107.png`, and `/tmp/tahoe-refraction-strength-matrix-center-20261107.png`. The run returned to the reference profile and restarted one current app service; its running executable SHA-256 matches the installed binary.

## 2026-11-07 Snell profile restored in the live KWin shader

The successful QML capsule profile is now used by the KWin compositor shader that paints the Control Center's live backdrop. Its optical settings are explicitly transferred: `MagnifyGlassStrength=0.15` maps to `refractScale=75`, `RefractionWidth=56` maps to a 35 px Snell edge band, and IOR is `1.7`. The depth calculation now uses the geometric rounded-rectangle inset (the old lens SDF was overly softened for this profile). The backdrop is still sampled from KWin's current scene textures; the standalone QML wallpaper sampling remains disabled. The Dock keeps its previous dome model.

To keep the high-angle Snell displacement stable on small compositor surfaces, the shader uses a smooth size-relative displacement bound and reduces the bend through the tightest capsule corners. This preserves the visible edge bend while avoiding large source-coordinate folds. RGB drift stays at zero.

The X11 plugin was installed at the versioned system plugin path with binary SHA-256 `5106230a61004e63e099ffcde7c7925f73857934c35173b05fc8fad184b2feb2`. Without restarting KWin or Plasma, the effect was unloaded and reloaded; KWin reports build identity `468930ec1913461da6634fac2b00df9418b3f2063d52cab489971267b9386028` and `isEffectLoaded(liquidglass)=true`. The active config remains `BlurStrength=4.0`, `MagnifyGlassStrength=0.15`, `RefractionWidth=56`, `RgbDriftStrength=0.0`, `WindowClasses=tahoe-control-center`, `BlurMatching=true`, and `BlurNonMatching=false`.

The isolated NVIDIA OpenGL Snell probe passes for both KWin shader variants. It verifies the bounded bend on a 140×62 Wi-Fi capsule at the active values, the effectively flat optical centre, and the curved-capsule fold tolerance. The broader legacy shader probe reaches a later Golden Gate client-fill contrast assertion after these Snell checks; the targeted Snell result is recorded separately from that broader failure.

The tray app now selects `QGuiApplication::primaryScreen()` for its popup, so a tray icon or mouse on another display cannot move the panel away from the center HDMI output. A fresh capture verified the window at `(3535,36)`, `304×496`, on HDMI-0 at `(1920,0)`; its panel crop is `/tmp/tahoe-snell-live-final-panel-20261107.png` and center-screen capture is `/tmp/tahoe-snell-live-final-center-20261107.png`. The capture showed the wallpaper beneath the glass; the compositor shader continues to sample live scene content when another window occupies that region. The temporary preview was closed afterward, leaving the single autostart tray instance active.

## 2026-11-07 X11 strength A/B with a static live source

The active effect's D-Bus `reconfigureEffect(liquidglass)` method was used for a controlled A/B on HDMI-0. This is the correct way to apply KWin effect settings during the comparison; reconfiguring KWin globally did not provide sufficiently controlled evidence in the earlier attempt. The normal managed test window remained below the Control Center in `_NET_CLIENT_LIST_STACKING` and drew fixed high-contrast diagonal and grid lines. The app's wallpaper shader remained disabled.

Captures: `/tmp/tahoe-ab-zero.png` (strength 0), `/tmp/tahoe-ab-point15.png` (0.15), and `/tmp/tahoe-ab-point25.png` (0.25); `/tmp/tahoe-ab-board.png` and `/tmp/tahoe-ab-015-vs-025.png` are enlarged side-by-side views. On the 340×600 crop around the panel, 0 vs 0.15 changed 86,075 pixels (mean luma difference 3.31); 0.15 vs 0.25 changed 7,786 pixels (mean luma difference 0.18). Thus the strength setting reaches the live shader, but the straight test marks still look nearly straight by eye at 0.15. This does not yet prove visually convincing optical displacement against the supplied macOS reference; do not call the goal complete from this A/B alone.

The preview and test source were closed after capture. Current runtime is one autostart tray process; `liquidglass` is loaded at build identity `66b126f0425e1a613ed19692b2bbc00be9423afbc203cf32a2fb8e025ab9e267`, with `MagnifyGlassStrength=0.15`, `BlurStrength=0.5`, `RgbDriftStrength=0.0`, and the Control Center class filter intact. The temporary green mask diagnostic is absent from source and the installed shader.

## 2026-11-07 refraction isolated from reflection

To avoid confusing specular highlights with bending, the pattern source was explicitly marked `_NET_WM_STATE_BELOW`, `HighlightStrength` was temporarily set to zero, and KWin was refreshed with `reconfigureEffect(liquidglass)` for each capture. At the restored `RefractionWidth=56`, the `MagnifyGlassStrength=0` versus `0.15` HDMI-0 captures differ in 11,695 pixels (mean luma difference 0.37 on the 340×600 panel-area crop). The amplified difference is concentrated on the capsule rims and sides; the card interiors and straight test marks remain nearly unchanged. This is evidence that the Snell uniform is reaching the current scene sample, but it also confirms the current profile is too edge-localized/subtle compared with the supplied macOS reference.

Evidence: `/tmp/tahoe-refraction-lowered-zero.png`, `/tmp/tahoe-refraction-lowered-point15.png`, `/tmp/tahoe-refraction-lowered-board.png`, and `/tmp/tahoe-refraction-lowered-diff-5x.png`. A wallpaper comparison of the reference profile and a temporary `RefractionWidth=112` is `/tmp/tahoe-refraction-width-board.png`; that wider band produced only a small visible gain, so the runtime was restored to `RefractionWidth=56`. `/tmp/tahoe-macos-vs-x11-015.png` shows the current wallpaper result beside the supplied reference. The setting A/B was captured on HDMI-0 at the rightmost panel area; the standalone app's QML wallpaper sampling remains disabled.

After the probe, the temporary windows were closed and the autostart tray service restarted. Current runtime was verified as one app process, loaded KWin identity `66b126f0425e1a613ed19692b2bbc00be9423afbc203cf32a2fb8e025ab9e267`, and `BlurStrength=0.5`, `MagnifyGlassStrength=0.15`, `RefractionWidth=56`, `HighlightStrength=0.14`, and `RgbDriftStrength=0.0`. Continue from the refraction profile itself; do not mistake the thin rim difference for a convincing match.

## 2026-11-07 bounded-corner candidate (built, not deployed)

The latest isolated profile preserves the 10.6 px bend at the 15 px inset on the 140×62 capsule, fades it to zero at the optical centre, and attenuates it inside the rounded-corner region. This avoids applying the grazing-angle singularity at the capsule silhouette. The Dock shader path is unchanged.

- `MTTKDE_GLASS_SNELL_ONLY=1 ./work/glass-shader-probe/glass-shader-probe src/offline/kwin-effects/acrylic-glass/src/shaders .` passes on the NVIDIA GeForce GTX 1050 Ti for both legacy and core shader variants, including no-fold popup checks down to 64×48 and the 140×62 capsule bend/centre checks.
- `cmake --build work/liquidglass-build -j2` succeeds. Built plugin SHA-256: `d0bc7795ed84b9ea904842ae8105585d04e2544c0230d53c1da791c23d56f384`.
- This candidate is not installed or active. KWin still maps the prior system plugin SHA-256 `a53a692c09059af8eb2a6babdcb5117d4e6acc9d997ab77c130c3a64f55400b2`. `sudo -n` reports that authentication is required, so the protected system plugin and running compositor were left untouched. The live HDMI-0 visual gate remains open.

## 2026-11-07 X11 client-shape recovery and live deployment

This supersedes the preceding “bounded-corner candidate (built, not deployed)” status. The candidate is now installed and active.

The remaining visual failure was in `clientBlurShapes()`: the two circular controls at the same row touched at one thresholded alpha pixel. Connected-component detection merged them into one 127×65 shape; fitting rejected that shape, and the all-or-nothing parser returned no client shapes. KWin therefore used the popup window outline for refraction. `splitTangentRoundShapes()` now recognizes only a balanced split whose two parts independently fit near-circular profiles. The actual app mask now produces 12 surfaces (including both separate circles) instead of an empty result. The targeted Qt-region test passes.

Verification on 2026-11-07:

- `pytest -q tests/test_acrylic_blur_region.py -k client_regions_only_move_for_server_decorations`: 1 passed.
- `make -j2` in `work/liquidglass-build`: X11 effect built successfully; `MTTKDE_GLASS_SNELL_ONLY=1 .../glass-shader-probe ...` passed on the GTX 1050 Ti.
- Isolated Xvfb test: KWin loaded the built X11 module, and a high-contrast live scene showed bending independently inside each capsule. The wallpaper-only isolated screenshot is `/tmp/tahoe-kwin-isolated-20261107/maskfix-wallpaper3.png`.
- Installed the immutable plugin at `/usr/lib/x86_64-linux-gnu/qt6/plugins/kwin-x11/effects/plugins/.mttkde-liquidglass/276aae57f6b5e236b7e68a6054319ce24a7e71486399ea927a8a9df0c761454d/liquidglass.so` (SHA-256 `276aae57f6b5e236b7e68a6054319ce24a7e71486399ea927a8a9df0c761454d`) and atomically switched the discovery symlink. Previous plugin binaries were left in place.
- Reloaded only the KWin effect over D-Bus; KWin reports build identity `2c9451d34abd740b1adf0107a2ef1228313615deeda95ffc89a89d63fcf241c4` and `liquidglass` is active. No KWin or Plasma restart was needed.
- Captured the existing production tray instance on the physical center HDMI-0 display, with the live Discord window beneath it: `/tmp/tahoe-control-center-hdmi0-live2.png`. A same-size side-by-side against the supplied reference is `/tmp/tahoe-control-center-live-compare-corrected.png`. The tray app was closed after capture; its single autostart service remains active.

The panel now samples live X11/KWin scene content, and the capsule lens deformation is visible on both a diagnostic line grid and the actual desktop. The direct comparison still shows a milder bend/highlight on the wallpaper than macOS; this deployment fixes the empty-shape fallback but does not claim pixel parity. Current runtime configuration was left unchanged (`BlurStrength=0.5`, `MagnifyGlassStrength=0.15`, `RefractionWidth=56`, `HighlightStrength=0.14`, `RgbDriftStrength=0.0`, class filter `tahoe-control-center`).
