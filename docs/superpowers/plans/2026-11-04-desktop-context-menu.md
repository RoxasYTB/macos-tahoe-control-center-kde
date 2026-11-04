# Tahoe Desktop Context Menu Implementation Plan

> For agentic workers: follow this plan in `/mnt/windata/C/Users/Yohan/Documents/Codex/2026-11-02/new-chat/work/macos-tahoe-liquid-kde`, inspect its working tree first, and preserve all existing local changes.

**Goal:** Make the KDE desktop right-click menu resemble the supplied Tahoe desktop context menu while preserving the real KDE actions.

**Architecture:** First trace which Plasma Folder View and style/theme code renders the active desktop menu; prefer styling the existing native menu over creating a replacement overlay. Reuse the theme's current translucent menu surfaces, selection color, typography and icon assets. Keep this work separate from the standalone Control Center app.

**Tech Stack:** KDE Plasma 6, QML/Plasma Folder View, Kvantum/Qt menu styling and the existing MacTahoe Liquid KDE theme assets.

## Global Constraints

- Reference: `image2.png` in `docs/macos-tahoe-reference-map.md`; preserve its exact row order and separators.
- Maintain actual KDE behavior for each menu action and submenu.
- Do not change the active desktop configuration or restart KWin/Plasma during visual iteration.
- The theme repository has pre-existing local modifications. Inspect `git status` and never stage or overwrite unrelated files.
- Keep the visual target convincing and efficient; pixel-perfect matching is not required.

---

### Task 1: Identify the live menu implementation

**Files:**
- Inspect: `/mnt/windata/C/Users/Yohan/Documents/Codex/2026-11-02/new-chat/work/macos-tahoe-liquid-kde/AGENTS.md`
- Inspect: `src/offline/look-and-feel/MacTahoeLiquidKde-Dark/contents/layouts/org.kde.plasma.desktop-layout.js`
- Inspect: `src/offline/plasma-theme/MacTahoeLiquidKde-Dark/`
- Inspect: the installed Plasma Folder View plugin and its current style integration without changing it

**Deliverable:** A short map naming the exact live QML/style files and theme assets responsible for desktop context menus; establish whether the menu is owned by Plasma or project code.

**Verification:** Confirm the selected source path is actually included by the theme's build/install path. Do not infer it from the unrelated taskbar `ContextMenu.qml`.

#### Verified implementation map — 4 November 2026

- Installed Plasma 6.7.4 routes a blank desktop right-click through `org.kde.desktopcontainment/contents/ui/FolderView.qml`. `FolderModel.usedByContainment` is true for the desktop root, so the folder view deliberately skips `dir.openContextMenu()` there and lets the event fall through to the desktop containment action.
- The desktop default maps `RightButton;NoModifier` to `org.kde.contextmenu` (`/usr/share/plasma/shells/org.kde.plasma.desktop/contents/defaults`). `Plasma::ContainmentItem` builds the native `QMenu`, sets `Qt::WA_TranslucentBackground`, fills it from the configured plugin, then opens it at the pointer. The relevant libplasma implementation is documented in [containmentitem.cpp](https://api.kde.org/legacy/plasma/libplasma/html/containmentitem_8cpp_source.html#l1602) and [addContainmentActions](https://api.kde.org/legacy/plasma/libplasma/html/containmentitem_8cpp_source.html#l1944). The `org.kde.contextmenu` plugin supplies the action order, separators, and actions such as wallpaper, desktop edit mode, and display settings; its source is [menu.cpp](https://github.com/KDE/plasma-workspace/blob/master/containmentactions/contextmenu/menu.cpp#L970-L999).
- `FolderModel::openContextMenu` is a separate native `QMenu` path for right-clicks on files/folders and folder widgets. It is useful for checking the same QMenu style, but it is not the blank-desktop containment menu.
- `FolderModel::openContextMenu` creates a `QMenu`, marks it `Qt::WA_TranslucentBackground`, attaches it to the originating `QQuickWindow`, and opens it at the pointer. The KDE upstream source is [foldermodel.cpp](https://github.com/KDE/plasma-desktop/blob/master/containments/desktop/plugins/folder/foldermodel.cpp#L1881-L2029).
- The menu is styled by the configured Kvantum style and `src/offline/kvantum/mac-tahoe-liquid-kde/mac-tahoe-liquid-kdeDark.kvconfig` plus `mac-tahoe-liquid-kdeDark.svg`. The install staging hook is `src/scripts/glass_surfaces.py`, called by `src/scripts/steps/kvantum.py`.
- An isolated Xvfb + KWin harness loaded the installed FolderModel plugin, opened its real empty-folder context menu and verified the native `Create New`, `Paste`, `Undo`, `Open Folder With` actions, icons, submenu arrows, hover row and translucent rounded surface. The harness uses the same Kvantum assets without installing or reloading the active desktop.
- Local render from that isolated session: `/tmp/folder-menu-preview-mactahoe-hover.png` (review artifact only; not packaged as product artwork).
- An isolated Xvfb Plasma 6.7.4 session with the correct `MacTahoeLiquidKdeDark` palette and the Kvantum SVG processed by `apply_kvantum_surface_defaults` opened the actual blank-desktop containment menu. It showed `Create New`, `Paste`, `Undo`, `Icons`, `Enter Edit Mode`, `Desktop and Wallpaper`, and `Display Configuration`. The latest local capture is `/tmp/tahoe-plasma-staged.ir3o2R/desktop-containment-menu.png` (review only; not product artwork).
- The menu body still renders opaque black in Xvfb, including with Picom XRender and a 32-bit Xvfb visual. A KWin-backed attempt also logged OpenGL framebuffer-context warnings. These runs confirm the actual menu/action path and the configured Kvantum assets, but they do not validate the desktop's composited alpha or blur. The active desktop was not changed.
- A Qt offscreen `QMenu` render using a temporary copy of the processed dark Kvantum theme looked gray when composited over `image3.png` (`/tmp/tahoe-menu-alpha-side-by-side.png`). With the dark Tahoe palette applied, the same offscreen grab returned alpha 255 and rendered as a solid dark rectangle (`/tmp/tahoe-menu-darkpalette-side-by-side.png`). These results show the offscreen widget grab is palette/backend-dependent and cannot validate actual window transparency; do not treat either preview as product evidence.
- Follow-up X11 probe with Xvfb + Picom GLX and the processed dark Kvantum SVG: the real `QMenu` popup window used a 32-bit ARGB visual and had a rounded `_KDE_NET_WM_BLUR_BEHIND_REGION`. `QMenu.grab()` returned alpha 81 (about 0.32) at sampled surface points and alpha 0 at the corners, matching the configured veil and rounded cutout. However, a root-screen XWD capture still displayed the popup as a black rectangle (`/tmp/tahoe-menu-picom-glx.png`), so it does not prove the final composited output. The temporary Qt process used the Kvantum style but fell back to BreezeLight because the Tahoe color scheme was not installed in its isolated config. Keep the screenshot classified as inconclusive.
- 4 November follow-up: an attempted Xvfb + `dbus-run-session` render produced an apparent translucent `QMenu` over the supplied desktop image. However, post-run process inspection found KWin and portal processes using `DISPLAY=:0` and the user's session bus, so the isolation boundary was not verified and the capture could have involved the active session. The full image and comparison sheet are retained as `../../../outputs/desktop-context-menu-unverified-session-20261104.png` and `../../../outputs/desktop-context-menu-comparison-unverified-session-20261104.png`, respectively, but are explicitly inconclusive. Do not use them as proof of compositing or as final product captures. No process was stopped after this discovery.
- 4 November private Kvantum render: a fresh Xvfb server allocated `:1`; the environment was rebuilt from a PATH/LANG/USER/LOGNAME allowlist, with private HOME/XDG directories and a fresh `dbus-run-session`. KWin answered only on that private session bus. The actual Kvantum Qt style rendered a QMenu using a staged copy of the installer's `DEST_DIR_DARK`, after applying `glass_surfaces.apply_kvantum_surface_defaults`. `menu.grab()` measured alpha 81/255 (0.318) at the interior and alpha 0 at a rounded corner, confirming the neutral 0.32 veil and rounded cutout in the widget render. Artifacts are `/tmp/tahoe-native-menu-isolated-20261104d/capture/menu-widget.png` and `desktop-composite.png`. The full-screen Xvfb capture has black outside the popup and is not valid backdrop-composition evidence; the test menu uses representative placeholder actions, not the live Plasma containment plugin. Keep this as style-surface evidence only, not proof of final compositor output or the actual desktop action menu.
- 4 November actual Plasma desktop menu render: KWin X11 and Plasma 6.7.4 ran on a fresh private Xvfb display and `dbus-run-session`; HOME, XDG config/data/cache and runtime were private, and the environment was filtered before launching either process. After dismissing KDE Welcome Center, a right-click opened the real desktop containment action menu. Spectacle captured the resting menu at `/tmp/tahoe-plasma-menu-isolated-20261104e/capture/desktop-context-menu-after-welcome.png`; moving over `Icons` opened its actual submenu and highlighted the row in `/tmp/tahoe-plasma-menu-isolated-20261104e/capture/desktop-context-menu-hover-icons.png`. The current dark Kvantum copy gives rounded outer corners, a translucent surface, readable KDE icons/shortcuts, separators and working chevrons. A side-by-side crop against `image2.png` is `/tmp/tahoe-menu-reference-vs-plasma-20261104.png`. Remaining visible differences: the KDE menu is wider because its real action labels and shortcut column need more room, its hover is saturated blue, and its interior fill reads as a square inset inside the rounded outer frame. The test used Plasma's default wallpaper, not the Tahoe wallpaper from the reference; it verifies the real menu/actions and theme styling, not exact backdrop matching. A temporary `interior=false`, reduced-frame variant made the content behind the menu too prominent and was discarded; the shipped source was not changed in this experiment.
- 4 November hover-color isolation follow-up: using a fresh private Xvfb + D-Bus session and the Tahoe wallpaper, changing `BackgroundNormal`/`BackgroundAlternate` under `[Colors:Selection]` in both temporary `kdeglobals` and the staged color-scheme file to muted purple did not change the actual desktop menu hover, which remained blue. Setting `respect_DE=false` and a purple `highlight.color` in the staged Kvantum config also did not change it. The capture is `/tmp/tahoe-plasma-menu-kvantum-highlight-20261104/desktop-context-menu-hover.png`; the isolated configs and run log remain under `/tmp/tahoe-plasma-menu-kvantum-highlight-20261104/`. These ineffective temporary changes were not copied into either repository. Treat the selection-color source as unresolved; no active desktop files or processes were changed.
- A separate private Plasma render with only `[Menu] frame.expansion=0` also produced no visible reduction in the native menu width. The setting was removed from the source and test; the observed width is dominated by the KDE action labels and shortcut column, so further width tuning needs a different approach and a fresh native-menu render.
- The Kvantum surface tests now assert the shipped 0.32 neutral veil and depth-6 popup shadow; they pass (`11 passed, 25 skipped`).
- KDE's native action set differs from the macOS Finder labels in `image2.png`; preserve the KDE actions and use that capture as a visual target for the menu surface, spacing, separators and hover treatment.

#### Remaining verification limits

- The actual containment menu, hover row and `Icons` submenu are now verified in a genuinely isolated Xvfb Plasma session. Continue visual tuning against `image2.png` only if a clear change can be tested in this harness; do not claim that the synthetic/default KDE wallpaper reproduces the Tahoe backdrop or that this verifies live blur/refraction on Yohan's desktop.
- A nested `kwin_wayland --virtual` render was also attempted with an isolated D-Bus session and temporary XDG configuration. KWin logged that the configured compositor was unsupported and fell back; Spectacle could not connect to PipeWire and did not produce a capture. The isolated processes were stopped, and this route does not resolve the alpha-render question.
- The reference has more rows than the native empty-folder menu; compare like-for-like surface behavior separately from the KDE action inventory.

### Task 2: Tune the desktop menu surface and rows

**Files:**
- Modify only the verified menu/style source identified in Task 1
- Modify corresponding dark theme asset(s) only when the source consumes them
- Add/update a focused visual reference note in `docs/macos-tahoe-reference-map.md`

**Deliverable:** Match the reference's compact floating panel, rounded corners, translucent dark surface, subtle edge, row spacing, small leading icons, separator placement and bright hover row. Keep the menu positioned at the pointer and fit it to available screen edges.

**Verification:** Capture the menu in an isolated Plasma test session or screenshot harness and compare it to `image2.png`; check each menu item and submenu opens the real KDE action.

### Task 3: Checkpoint only the context-menu change

**Files:**
- Only the reviewed menu/style files from Task 2

**Deliverable:** One focused checkpoint on the existing theme development checkpoint branch. Do not create a pull request yet.

**Verification:** Run the repository's targeted static/style validation for changed files, inspect staged paths, and verify remote branch SHA. Do not install the theme or reload the active desktop as part of this checkpoint.
