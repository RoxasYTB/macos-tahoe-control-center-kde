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
- The desktop default maps `RightButton;NoModifier` to `org.kde.contextmenu` (`/usr/share/plasma/shells/org.kde.plasma.desktop/contents/defaults`). `Plasma::ContainmentItem` gathers the configured plugin's `QAction`s and opens a native `QMenu`; the corresponding libplasma implementation is documented in [containmentitem.cpp](https://api.kde.org/legacy/plasma/libplasma/html/containmentitem_8cpp_source.html#l1944). The `org.kde.contextmenu` plugin supplies the action order, separators, and actions such as wallpaper, desktop edit mode, and display settings; its source is [menu.cpp](https://github.com/KDE/plasma-workspace/blob/master/containmentactions/contextmenu/menu.cpp#L970-L999).
- `FolderModel::openContextMenu` is a separate native `QMenu` path for right-clicks on files/folders and folder widgets. It is useful for checking the same QMenu style, but it is not the blank-desktop containment menu.
- `FolderModel::openContextMenu` creates a `QMenu`, marks it `Qt::WA_TranslucentBackground`, attaches it to the originating `QQuickWindow`, and opens it at the pointer. The KDE upstream source is [foldermodel.cpp](https://github.com/KDE/plasma-desktop/blob/master/containments/desktop/plugins/folder/foldermodel.cpp#L1881-L2029).
- The menu is styled by the configured Kvantum style and `src/offline/kvantum/mac-tahoe-liquid-kde/mac-tahoe-liquid-kdeDark.kvconfig` plus `mac-tahoe-liquid-kdeDark.svg`. The install staging hook is `src/scripts/glass_surfaces.py`, called by `src/scripts/steps/kvantum.py`.
- An isolated Xvfb + KWin harness loaded the installed FolderModel plugin, opened its real empty-folder context menu and verified the native `Create New`, `Paste`, `Undo`, `Open Folder With` actions, icons, submenu arrows, hover row and translucent rounded surface. The harness uses the same Kvantum assets without installing or reloading the active desktop.
- Local render from that isolated session: `/tmp/folder-menu-preview-mactahoe-hover.png` (review artifact only; not packaged as product artwork).
- KDE's native action set differs from the macOS Finder labels in `image2.png`; preserve the KDE actions and use that capture as a visual target for the menu surface, spacing, separators and hover treatment.

#### Remaining verification limits

- The isolated harness verifies the real `FolderModel` menu and the shared native QMenu style integration. It does not execute Plasma's desktop containment action plugin or its wallpaper/widget configuration actions, and it is not a live screenshot of Yohan's full desktop. The blank-desktop route is now identified; its own isolated integration render remains to be done.
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
