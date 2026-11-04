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

---

### Task 1: Preserve and register the visual references

**Files:**
- Read: `docs/macos-tahoe-reference-map.md`
- Read: `docs/reference-assets/macos-tahoe-control-center/wifi-hover-chevron.png`
- Read: all original paths listed in `docs/macos-tahoe-reference-map.md`

**Deliverable:** Every editor, network menu, hover and desktop context-menu acceptance point is traceable to a supplied image and SHA-256. Use the local hover crop when testing the tiny chevron.

**Verification:** Recompute the six listed hashes and confirm dimensions with Pillow. Do not add the five desktop screenshots to public product artwork or overwrite them.

### Task 2: Add reusable hover and trailing-chevron behavior

**Files:**
- Modify: `contents/ui/components/QuickTile.qml`
- Modify: `contents/ui/components/ControlCenterPanel.qml`
- Modify: `contents/ui/components/icons/` only for a small project-owned chevron if Qt's standard chevron does not match
- Modify: `docs/macos-tahoe-reference-map.md` only if a measured behavior is clarified

**Deliverable:** Wi‑Fi and Bluetooth capsules brighten subtly on hover/focus without resizing or moving their icon/text. Wi‑Fi shows a small right-facing chevron aligned to the capsule end while hovered/focused; clicking it or pressing Enter opens details. Preserve normal tile activation for non-menu controls.

**Verification:** Render resting, hover, keyboard-focus and pressed states in the offline harness. Confirm there is no permanent chevron and no geometry shift when it appears.

### Task 3: Implement Wi‑Fi and Bluetooth detail popovers

**Files:**
- Create: `contents/ui/components/ControlDetailsPopup.qml`
- Modify: `contents/ui/components/ControlCenterPanel.qml`
- Modify: `app/SystemControlController.h`
- Modify: `app/SystemControlController.cpp`
- Modify: `app/controlcenter.qrc`
- Modify: `app/CMakeLists.txt` only if new C++ model sources are needed

**Deliverable:** Anchored glass popovers match the supplied right-top screenshots. Wi‑Fi shows its power switch, known network and lock, expandable “Other Networks”, and “Wi‑Fi Settings…”. Bluetooth shows its power switch, paired/available device rows with truthful states, and “Bluetooth Settings…”. Escape and outside click dismiss; opening one popover closes the other. All toggles act on NetworkManager/BlueZ.

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

### Task 6: Verify and checkpoint the Control Center work

**Files:**
- Build: `app/CMakeLists.txt`, QRC assets and QML components touched above
- Render: `work/render_theoretical_glass.py` and the existing private preview target
- Document: `README.md` and `docs/macos-tahoe-reference-map.md`

**Deliverable:** A compact comparison sheet for editor top/bottom views, Wi‑Fi/Bluetooth submenus and hover states, with the corresponding references alongside. A GitHub checkpoint contains only reviewed changes for this app; no pull request until the overall work is finished.

**Verification:** Build `tahoe-control-center` and `controlcenter_visual_preview`; render each view in Xvfb and check shader diagnostics; inspect the complete diff and Git status to ensure unrelated work remains untouched. Do not run a live KWin-effect test.
