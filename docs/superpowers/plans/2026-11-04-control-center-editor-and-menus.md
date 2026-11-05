# Control Center Editor and Network Menus Implementation Plan

> For agentic workers: execute the tasks in order, validate each deliverable, and keep the host desktop usable throughout.

**Goal:** Add the macOS-style Controls editor, Wi‑Fi and Bluetooth detail popovers, and their hover interactions to the standalone KDE Control Center.

**Architecture:** Keep the native tray host and current `ControlCenterPanel.qml`; add focused QML components for the editor and detail popovers. Reuse the existing `SystemControlController` and extend it only for real network/device data and editable control layout persistence. Build all views in the private screenshot harness before any live launch.

**Tech Stack:** C++17, Qt 6.6+, Qt Quick/QML, Qt DBus, NetworkManager (`nmcli`) and BlueZ (`bluetoothctl`), existing LiquidGlass shaders and Cupertino/project SVG icons.

## Global Constraints

- Target a convincing, useful result quickly; do not perform exhaustive pixel sweeps.
- Use the exact screenshot inventory in [`docs/macos-tahoe-reference-map.md`](../../macos-tahoe-reference-map.md).
- Do not bake a wallpaper or desktop screenshot into the live application; popovers must show the live content behind them.
- Preserve independent glass surfaces in the main Control Center; the editor alone has one continuous panel surface as shown in the reference.
- Do not enable or restart the separate KWin Liquid Glass effect on the active desktop.
- Keep actions connected to KDE/system APIs; show unavailable data as unavailable, never fabricate device/network states.
- Preserve Cupertino/project icon licenses and all unrelated local changes. Do not package Apple's SF Symbols or Apple Design Resources as app assets.
- Keep desktop context-menu implementation in its own plan/repository; this plan only covers the dedicated Control Center app.
- Treat `docs/macos-tahoe-reference-map.md` as the authoritative inventory for the supplied editor, desktop, Wi-Fi and Bluetooth captures. Preserve the originals and hashes; the small `wifi-hover-chevron.png` crop is the specific reference for the hover arrow and subtle capsule brightening.

---

### Task 1: Preserve and register the visual references

**Files:**
- Read: `docs/macos-tahoe-reference-map.md`
- Read: `docs/reference-assets/macos-tahoe-control-center/wifi-hover-chevron.png`
- Read: all original paths listed in `docs/macos-tahoe-reference-map.md`

**Deliverable:** Every editor, network menu, hover and desktop context-menu acceptance point is traceable to a supplied image and SHA-256. Use the local hover crop when testing the tiny chevron. The map records that hover also brightens the capsule subtly, while its icon/text stay centered and the geometry does not shift.

**Verification:** Recompute the six listed hashes and confirm dimensions with Pillow. Do not add the five desktop screenshots to public product artwork or overwrite them.

### Task 2: Add reusable hover and trailing-chevron behavior

**Files:**
- Modify: `contents/ui/components/QuickTile.qml`
- Modify: `contents/ui/components/ControlCenterPanel.qml`
- Modify: `contents/ui/components/icons/` only for a small project-owned chevron if Qt's standard chevron does not match
- Modify: `docs/macos-tahoe-reference-map.md` only if a measured behavior is clarified

**Deliverable:** Wi‑Fi and Bluetooth capsules brighten subtly on hover/focus without resizing or moving their icon/text. Wi‑Fi shows a small right-facing chevron aligned to the capsule end while hovered/focused; hide it at rest, and do not let it shift the centered icon or label. Clicking the capsule or pressing Enter opens details. Preserve normal tile activation for non-menu controls.

**Verification:** Render resting, hover, keyboard-focus and pressed states in the offline harness. Confirm there is no permanent chevron and no geometry shift when it appears.

### Task 3: Implement Wi‑Fi and Bluetooth detail popovers

**Files:**
- Create: `contents/ui/components/ControlDetailsPopup.qml`
- Modify: `contents/ui/components/ControlCenterPanel.qml`
- Modify: `app/SystemControlController.h`
- Modify: `app/SystemControlController.cpp`
- Modify: `app/controlcenter.qrc`
- Modify: `app/CMakeLists.txt` only if new C++ model sources are needed

**Deliverable:** Anchored glass popovers match the supplied right-top screenshots. Wi‑Fi shows its power switch, known network and a lock only when NetworkManager reports security for the active network, expandable “Other Networks”, and “Wi‑Fi Settings…”. Bluetooth shows its power switch, paired/available device rows with truthful states, and “Bluetooth Settings…”. Escape and outside click dismiss; opening one popover closes the other. All toggles act on NetworkManager/BlueZ.

**Verification:** Check QML rendering for connected, disconnected, no-network, powered-off, no-adapter and unavailable-command states. Verify device/network labels come from the system controller and settings actions launch the appropriate KDE settings module where installed.

### Task 4: Build the Controls editor window

**Files:**
- Create: `contents/ui/components/ControlEditor.qml`
- Create: `contents/ui/components/ControlEditorTile.qml`
- Create: `app/ControlLayoutModel.h`
- Create: `app/ControlLayoutModel.cpp`
- Modify: `app/Main.qml`
- Modify: `app/controlcenter.qrc`
- Modify: `app/CMakeLists.txt`
- Modify: `app/TrayController.h` and `app/TrayController.cpp` only for window lifecycle if needed

**Deliverable:** An editor view with a fixed bottom action bar, independently scrolling category rail and control catalog, search box, selected category row, section headers, suggestions and the controls shown in both references. Include the visible category names in the order in the reference map; do not invent rows below the cropped region. Support keyboard navigation and screen-reader names.

For the 820 × 937 `image5.png` crop, target an editor panel about 735 × 900 px with a 244 px category rail and a 60 × 28 px Done button. Let the catalog flow variable-width tiles across each row: about 62 px for circles and 138 px for capsules/large controls. This lets the Suggestions row fit the large accessory tile, two circular clock controls and the wide window-tiling capsule, as shown. Use the existing Cupertino font and project-owned SVG icons rather than generic Unicode symbols. The selected-layout chips are an implementation affordance absent from the reference, retained for removal/reordering; keep them compact and verify that the Connectivity section remains reachable below the fixed footer by scrolling.

**Verification:** Compare the initial view against `image5.png` and the scrolled view against `image6.png` at their original dimensions. Check clipping, scroll ownership, fixed Done footer, and no shared panel in the main Control Center.

### Task 5: Make controls editable and persistent

**Files:**
- Modify: `contents/ui/components/ControlEditor.qml`
- Modify: `contents/ui/components/ControlEditorTile.qml`
- Modify: `contents/ui/components/ControlCenterPanel.qml`
- Modify: `app/ControlLayoutModel.h` and `app/ControlLayoutModel.cpp`
- Modify: `app/SystemControlController.h` and `app/SystemControlController.cpp` only for persisted layout access

**Deliverable:** Drag a catalog tile into Control Center or Menu Bar, reorder/remove configurable controls, and apply changes with Done. Store the user's selected controls and ordering using `QSettings`; restore the saved layout when the app starts. Keep Wi‑Fi, Bluetooth, Display, Sound, AirDrop and Focus behavior/status consistent with their existing capabilities.

**Verification:** Save a changed layout, close/reopen the editor and app, and confirm it persists. Exercise drag cancellation, dropping on invalid targets, empty search, no-results search, duplicate drops and Done with no changes.

#### Current isolated interaction checks — 4 November 2026

- Status rendering now distinguishes adapter availability from radio power: the main panel, editor previews, and Wi-Fi/Bluetooth detail popovers use actual `SystemControlController` state and say “Unavailable” when the host has no corresponding device. Battery preview reads `/sys/class/power_supply/*/{type,capacity}` and no longer invents “100 %”. AirDrop stays unavailable as agreed.
- Read-only host snapshot during this pass: NetworkManager reports Wi-Fi radio enabled but no Wi-Fi device, `bluetoothctl show` reports an available powered controller, and `/sys/class/power_supply` has no battery entry. These values are machine-specific; the UI remains bound to live queries.
- Read-only brightness capability check: `/sys/class/backlight` has no entries and `brightnessctl` is not installed; the controller has no brightness setter. The default and custom Display sliders now show “Unavailable” with no fabricated filled level and remain non-interactive on this host.
- After the Display availability change, `tahoe-control-center` builds and `qmllint` reports zero syntax/error diagnostics for `SliderCard.qml` and `ControlCenterPanel.qml`. No live UI render was used for this change.
- Bluetooth detail rows keep paired devices visible but only allow connect/disconnect while a controller is available and powered on; inactive rows use the subdued text treatment. `pragma ComponentBehavior: Bound` scopes the popup's parent state into the repeater delegate. The app target builds and `qmllint` reports zero errors and seven remaining unqualified `modelData` warnings. This state transition was not clicked against the user's live Bluetooth controller.
- Bluetooth menu device rows now preserve BlueZ's paired-device order; connected devices missing from the paired query are appended in the order returned by BlueZ. This avoids a hash-order/alphabetical reshuffle relative to the system device list. The app target builds after the change; no live Bluetooth connection state was modified.
- `cmake --build .build/app --target tahoe-control-center -j2` completed successfully after the availability changes; `git diff --check` reported no whitespace errors. No active Plasma/KWin session was restarted or altered.

- In Xvfb with a temporary `XDG_CONFIG_HOME`, dragged a catalog tile into the Control Center chips and into Menu Bar; each appeared in the saved settings after Done.
- Clicked the AirDrop chip and confirmed it was removed from the saved Control Center list.
- Dragged Bluetooth before AirDrop and confirmed the changed order in `controlCenterItems` after Done.
- Dragged Run Shortcut before Scene or Accessory and confirmed the changed order in `menuBarItems` after Done.
- Relaunched the app with each temporary settings directory and captured the editor; both changed chip orders were restored on startup.
- These checks used `/tmp/tahoe-*-config*`; the user's real KDE settings were not read or changed.
- In a separate Xvfb display (`:137`) with its own D-Bus session and KWin, opened Wi‑Fi, expanded “Other Networks”, then clicked the blank panel area; the details popup closed and the independent capsules returned. Clicking a separate target window in normal mode closed the Control Center window as well. The live network state was shown as “Not Connected”; no network toggle was used.
- The same temporary Xvfb checks were repeated after adding a background click target behind the detail popup. Its interior remained interactive, while a click outside the popup dismissed it.
- In an isolated Xvfb/KWin render, the Wi‑Fi chevron was absent at rest and visible on hover; the capsule changed in 5,668 pixels in the sampled crop. Pressing Tab focused Wi‑Fi and showed the same chevron without moving its icon or label. Captures are `/tmp/tahoe-hover-rest.png`, `/tmp/tahoe-hover-active.png` and `/tmp/tahoe-keyboard-focused-crop.png`.
- 5 November follow-up: expanded Wi‑Fi “Other Networks” rows are now actionable by click or keyboard Enter. The app asks NetworkManager to connect using any saved credentials; if that connection fails (for example, the network needs credentials not saved in NetworkManager), it opens KDE Network settings. No password is collected or persisted by this app. The Control Center target builds successfully, `qmllint` reports no diagnostics for `ControlDetailsPopup.qml`, and `git diff --check` passes. In Xvfb with a private D-Bus and temporary XDG config, a fake `nmcli` supplied `HomeNet` and `GuestNet`; clicking `GuestNet` recorded `device wifi connect GuestNet`. No real network was selected or changed. This verifies the UI-to-controller command path, not NetworkManager's real connection flow.
- 5 November Bluetooth interaction check: in a separate Xvfb run with private D-Bus/XDG settings and fake `bluetoothctl` output, the popup displayed a paired `MX Master` row; clicking it recorded `connect 12:34:56:78:9A:BC`. This verifies the device-row action path without connecting or changing a real Bluetooth device. The actual BlueZ device connection remains untested.
- Rendered the editor alone at 735 × 900 in an isolated Xvfb display matching the supplied editor window size (`/tmp/tahoe-editor-reference-size-after.png`). The two content regions retain vertical scrolling, and horizontal scrollbars were suppressed because they appeared from minor Flow overflow and obscured the last category rows. This first preview exposed a mismatch: the selected-layout chip area covered the captions below Connectivity.
- The layout-assignment chips now start collapsed so the initial editor view exposes all three Connectivity captions. Clicking the footer instruction expands the Control Center and Menu Bar chip rows; selected chips still remove on click and reorder by drag. Renders: `/tmp/tahoe-editor-top-collapsed.png` and `/tmp/tahoe-editor-layout-expanded.png`. An isolated Xvfb pointer click on the footer instruction opened the rows and showed both assignment labels (`/tmp/tahoe-editor-layout-clicked.png`). These previews used temporary `XDG_CONFIG_HOME` directories and did not alter the user's saved layout. The expanded management state intentionally uses more catalog height than the reference; the default view is the one compared to `image5.png`.
- The editor window now uses the existing native `BlurBehindRegion` helper with its own 735 × 900 rounded alpha mask, packaged as `app/control-editor-blur-window-region.png`. In an isolated Xvfb/KWin run, the editor exposed `_KDE_NET_WM_BLUR_BEHIND_REGION` as a non-empty CARDINAL rectangle list (172 values) at its native window; that earlier check verified mask loading and X11 property setup only.
- 4 November follow-up: the standalone Control Center was opened in a fresh Xvfb `:79` session with private HOME/XDG directories and a private D-Bus session. KWin's `supportInformation` reported OpenGL compositing active and `blur` under “Currently Active Effects”. The app's native `Control Center` client window (`0xc00011`) exposed a non-empty `_KDE_NET_WM_BLUR_BEHIND_REGION` CARDINAL list covering the rounded glass surface. Spectacle capture: `/tmp/tahoe-controlcenter-composited-20261104d/controlcenter-composited.png`. Its backdrop was a real full-screen X11 window rendering the user's wallpaper image, not a pre-composited screenshot; the capture shows the independent surfaces over that window. This verifies KWin's isolated compositing path and blur-region request, not the user's active desktop, arbitrary foreground applications, or live shader refraction. The active Control Center implementation currently sets `useLiquidGlass: false` in `app/Main.qml`, so do not describe this check as validating the LiquidGlass shader.
- 4 November KWin Liquid Glass app-surface verification: launched the built `tahoe-control-center --show --stay-open` over a live Qt window in the background in a fresh private Xvfb `:1`, D-Bus and KWin X11 session. KWin loaded the installed `liquidglass.so` from a private plugin copy; `/Effects` listed it active and `/proc/<kwin-pid>/maps` confirmed that exact private path. With one fixed high-contrast band/diagonal-line pattern painted by that background window, the effects-on/off full-screen difference was confined to the Control Center window bounds `(975,41)-(1267,523)`: 52,551 pixels in the panel crop changed by more than 8 RGB levels and zero pixels changed outside the window. The effects-on screenshot shows the background application's content through and distorted by the app's independent glass capsules. Captures: `/tmp/tahoe-cc-glass-probe-y8X66A/effect-on-a.png` and `effect-off.png`. This confirms the KWin effect path for the standalone app's published blur region; it does not validate the active desktop, app behavior on Wayland, or final parameter matching against the macOS wallpaper. `useLiquidGlass: false` in `app/Main.qml` disables the separate plasmoid shader that samples Plasma's wallpaper item; it does not disable KWin's Liquid Glass effect on the application window.
- 4 November editor appearance follow-up: in a separate Xvfb `:81` + private D-Bus/KWin session, clicked “Edit Controls” in the standalone application's real Control Center window and captured the resulting 735 × 900 editor at `/tmp/tahoe-controlcenter-composited-20261104-editor-after/control-editor-composited.png`. The sidebar and suggestion tiles now use translucent purple surfaces, so the wallpaper is visible across the editor instead of the sidebar reading as an opaque dark block. Compared with `image5.png`, the suggestion grid still differs in the placement/height of its two large tiles, and several preview glyphs remain approximations. The active desktop and saved layout were untouched.
- 4 November suggestion-grid correction: extracted the catalogue card into `contents/ui/components/ControlEditorTile.qml` and registered it in `app/controlcenter.qrc`. The Suggestions section now places the two tall 138 × 138 controls beside the circle and pill controls using the reference's compact staggered arrangement; the bulb, alarm, stopwatch, timer and shortcut stack use Cupertino glyphs. The first render exposed duplicate entries in later sections because hidden Repeater delegates remained instantiated; gating each repeater's model fixed the duplicates. Build and isolated Xvfb render succeeded with no QML diagnostics. Final capture: `/tmp/tahoe-controlcenter-composited-20261104-editor-reference-opening/control-editor-composited.png`.
- In isolated Xvfb `:86` with private HOME/XDG and D-Bus, clicked the “Scene or Accessory” large suggestion, then Done. The temporary `QSettings` file recorded `Scene or Accessory` at the end of `controlCenterItems`, confirming the extracted card's click signal and persistence path. No real user setting was touched.
- The editor now closes the small Control Center popover before showing the editor, matching the supplied full-desktop editor capture. The latest `:87` capture shows the editor by itself over the desktop. The reference icon drawings and exact typography remain approximate; do not claim pixel parity.
- Bluetooth device rows now choose a Cupertino phone, headphones, speaker, keyboard, mouse/pointer or generic-computer glyph from the live BlueZ device name rather than showing generic music/Bluetooth characters. `tahoe-control-center` rebuilt successfully, and an isolated Xvfb run opened the Bluetooth popover using current BlueZ results; capture: `/tmp/tahoe-bluetooth-popup-preview-20261104/bluetooth-popup.png`. This checked QML loading, icons and live device rows without the user's desktop; Xvfb had no KWin compositor or wallpaper, so the capture does not validate glass blur/refraction.
- Adapter absence no longer disables the Wi-Fi/Bluetooth detail capsule itself in the default or custom layout: with a controller present, users can open the detail popup and see “Unavailable”; its hardware power switch remains disabled. The default Wi-Fi path was clicked and captured in isolated Xvfb at `/tmp/tahoe-bluetooth-popup-preview-20261104/wifi-popup.png`, showing the unavailable status and inactive switch. This verifies the fallback UI only, not live compositor behavior.
- 4 November editor icon correction: the “Start Screen Saver” suggestion now uses a project-owned SVG screen/moon/star glyph matching the supplied tile instead of a plain crescent. The app rebuilt successfully and `--editor-preview` rendered in isolated Xvfb at `/tmp/tahoe-editor-ss-icon/editor.png`. That black-background capture verifies the QML/resource path and icon only; it does not validate glass or desktop compositing.
- 4 November editor reference comparison: rendered the editor in a fresh private Xvfb `:94` + D-Bus/KWin session and cropped the 735 × 900 app window from the full-screen capture (`/tmp/tahoe-control-editor-label-20261104/editor-crop.png`). Compared against the 735 × 900 panel crop of `image5.png`. The large “Start Screen Saver” tile was missing its in-tile title, visible in the macOS capture above the repeated caption; `ControlEditorTile.qml` now renders that title inside the card. The new isolated capture shows both labels without overlap. Battery and Wi‑Fi remain “Unavailable” because this host reports no battery or Wi‑Fi adapter; no state was fabricated. This verifies layout/resource rendering under KWin, not pixel parity or the user's active desktop.

### Task 6: Verify and checkpoint the Control Center work

**Files:**
- Build: `app/CMakeLists.txt`, QRC assets and QML components touched above
- Render: `work/render_theoretical_glass.py` and the existing private preview target
- Document: `README.md` and `docs/macos-tahoe-reference-map.md`

**Deliverable:** A compact comparison sheet for editor top/bottom views, Wi‑Fi/Bluetooth submenus and hover states, with the corresponding references alongside. A GitHub checkpoint contains only reviewed changes for this app; no pull request until the overall work is finished.

**Verification:** Build `tahoe-control-center` and `controlcenter_visual_preview`; render each view in Xvfb and check shader diagnostics; inspect the complete diff and Git status to ensure unrelated work remains untouched. Never enable or test KWin effects on the user's active desktop; an isolated Xvfb/KWin compositor render is allowed and must be labeled as isolated evidence.

### Follow-up: explain an empty editor search

- Added a centered `No Controls Found` / `Try a different search term.` state when a non-empty search has no catalog matches.
- Validation: `tahoe-control-center` builds successfully; an isolated Xvfb editor preview with the actual query `zzzz-no-such-control` displayed the empty state. This validates the search-empty UI only, not the live Plasma host or visual glass.
- 4 November scrolled-catalog comparison against `image6.png` found that ordinary category controls were packed into six columns. Wrapped them into three equal-width cells with centered tiles and 110 px row cells. The new isolated Xvfb render at `/tmp/tahoe-editor-scroll-check/scrolled-3col-spaced.png` shows the same three-column order for Desktop & Finder and Display & Brightness as the reference, with Fast User Switching reachable below; the `735 × 900` window and fixed Done footer remain intact. Build succeeded. This checks layout only; the private preview's backdrop remains opaque and is not evidence for glass rendering.
- 5 November tray popover correction: the Wi-Fi and Bluetooth tray icons now request standalone detail popovers (matching the supplied top-right menu references) without leaving the full Control Center visible underneath. Clicking Wi-Fi/Bluetooth capsules inside the Control Center continues to open details in-place. The window height follows the selected popover, and closing it resets tray visibility. The test-only `--menu-preview wifi|bluetooth` path now enters through `TrayController::activateMenuBarControl`, the same signal path as the tray icons. `tahoe-control-center` builds and `git diff --check` passes. Prior isolated KWin captures for the standalone mode are `/tmp/tahoe-cc-menubar-preview-20261105/wifi-menu-only.png` and `bluetooth-menu-only.png`; they predate the final signal-path refactor, so they evidence the standalone layout/compositing but not this exact signal change. No new graphical run was completed after that refactor; this remains to be rechecked. Wi-Fi is unavailable on the test host; Bluetooth rows reflect the host's live BlueZ devices.
- 5 November close-behavior recheck: in a private Xvfb + KWin session, a real `xmessage` window was placed behind the standalone Wi-Fi popover. Clicking that background window dismissed the popover; the resulting capture `/tmp/tahoe-menu-kwin-check-20261105/after.png` shows the background window and no menu. This corrects the earlier check, which searched by title and mistakenly counted the hidden host window. A separate Escape attempt left the popup X window mapped (`IsViewable`) even after clicking it and sending Escape; this is a credible unresolved keyboard-close issue, although synthetic key routing in this harness is not yet fully qualified. No code workaround was retained because initial attempts did not change that result. Build succeeds; active Plasma/KWin was untouched.
- 5 November standalone tray-path recheck: launching the built app with `--menu-preview wifi` after the tray signal-path refactor opens the Wi-Fi detail popover by itself at the top-right; the host correctly reports `Unavailable`. Capture: `/tmp/tahoe-final-popover-wMUgj8/wifi-menu.png`. This Xvfb screen had no wallpaper/background window, so it verifies the final open path and unavailable state only, not glass or live backdrop appearance. A QML diagnostic build logged the details `Popup` at `activeFocus: true` when opened. With the app window explicitly activated, sending Escape still left the Wi-Fi panel visible in `/tmp/tahoe-escape-focused-iEXgLw/after.png`; the Xvfb backdrop was empty/black. This reproduces the Escape failure with the documented focus precondition satisfied. No diagnostic source changes were retained; active Plasma/KWin was not touched.
- 5 November Escape fix: an isolated Qt event-filter trace showed that, while the Wi-Fi popup was open, Escape was routed to the `QQuickShortcut` owned by the hidden `ControlEditor` window. The editor shortcut now uses `enabled: root.visible`, so it cannot consume Escape while hidden. With that single change and the existing popup close policy, the built `--menu-preview wifi` window disappears after activating it and sending Escape; verification used `xdotool search --onlyvisible` (the X11 tree includes unmapped windows). `cmake --build .build/app --target tahoe-control-center -j2` and `git diff --check` pass. The app was run only under private Xvfb/KWin; the active desktop was untouched.
- 5 November final tray-path glass recheck: the rebuilt app was launched via `--menu-preview wifi` in a fresh private Xvfb/KWin session with the isolated Liquid Glass plugin explicitly loaded (verified through KWin's `/Effects` API and `/proc/<kwin-pid>/maps`). A moving foreground window with high-contrast colored bars/diagonals sat behind the popover. The effect-on/off captures are `/tmp/tahoe-tray-glass-final-MnXLWQ/effect-on-a.png` and `effect-off.png`; they confirm the tray path renders over live window content and the effect changes the glass surface. This diagnostic backdrop intentionally exaggerates distortion and is not a visual-fidelity comparison. The app used its host-derived Wi-Fi-unavailable state; no active Plasma/KWin state was changed.
- 5 November Bluetooth tray-path check: the same isolated KWin/Liquid Glass harness opened `--menu-preview bluetooth`; capture `/tmp/tahoe-tray-bluetooth-final-eZU7Sx/effect-on-a.png` shows the final standalone popup populated from BlueZ. Read-only host state reported the `rebecca` controller powered on, five paired devices and no connected devices; the popup displays the first four paired rows as inactive and the controller toggle on. No Bluetooth connection or power state was changed. The high-contrast diagnostic backdrop exaggerates glass distortion and does not assess final fidelity.
- 5 November editor persistence check: in a fresh Xvfb run with private XDG directories, clicked the `Voice Memo` suggestion, pressed `Done`, closed the app and relaunched `--editor-preview` with the same temporary profile. `config/RoxasYTB/Tahoe Control Center.conf` retained `Voice Memo` at the end of `controlCenterItems`; the restarted editor showed the selected-layout rows in `/tmp/tahoe-editor-persist-run-9Odtvs/after-restart.png`. This verifies the Done-to-QSettings write and reload path without changing the user's saved layout.
- 5 November current-binary dismissal recheck: with a fresh private HOME/XDG tree, D-Bus, Xvfb and KWin, `--menu-preview wifi` closed after Escape (no visible Control Center window remained). On a second launch, an `xmessage` window behind the popover received an outside click and the popover closed. Results: `/tmp/tahoe-cc-popover-current-20261105/escape-result.txt` and `outside-result.txt` both report `PASS`. This rechecks the actual built binary after the earlier Escape failure and shortcut fix. The host Wi-Fi state was unavailable in the test view; no radio or network was changed. Active Plasma/KWin was untouched.
