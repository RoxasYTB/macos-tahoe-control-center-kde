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
