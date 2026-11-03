# Standalone Control Center Application Implementation Plan

> **For agentic workers:** Follow the tasks below in order and keep each verification result with its task.

**Goal:** Replace the Control Center plasmoid runtime with a small Qt Quick application that lives in the system tray and opens/closes a native popup window.

**Architecture:** Keep the existing `ControlCenterPanel.qml` and artwork. Add a C++ `QApplication` with a `QSystemTrayIcon`; use Qt Quick `Window` with popup flags for the visual panel. Capture the screen area before showing the popup and pass the hidden image to each LiquidGlass card. Do not enable KWin Acrylic Glass or a shared blur region behind the popup. Build/install as a user-local application with a desktop entry and autostart entry.

**Tech Stack:** C++17, Qt 6 Gui/Qml/Quick, KF6 WindowSystem, QML, CMake, StatusNotifier via `QSystemTrayIcon`.

## Global Constraints

- Use a hidden capture of the actual desktop area beneath the popup; never paint a wallpaper into the production window.
- Keep all transparent gaps between cards free of KWin Acrylic Glass or a common blurred/tinted panel.
- Keep each glass card visually independent and preserve the current panel geometry/icons.
- The tray icon must use the supplied IconScout control-centre artwork.
- Keep device controls inert during this visual stage.
- Do not add right-click menu behavior to this task.
- Preserve the existing plasmoid source until the standalone app has been built and visually verified.

---

### Task 1: Add the standalone application target

**Files:**
- Create: `app/CMakeLists.txt`
- Create: `app/main.cpp`
- Create: `app/TrayController.h`
- Create: `app/TrayController.cpp`
- Create: `app/Main.qml`
- Create: `app/controlcenter.qrc`
- Create: `build-app.sh`

**Deliverable:** A CMake target that embeds QML and artwork, starts hidden with a QSystemTrayIcon, toggles a transparent `Qt.Popup` window on tray activation, and supports `--show` for live inspection.

**Verification:** Configure/build the target; launch with `--show`; confirm the transparent popup is visible and closes on Escape/outside click. Run without `--show`; confirm the tray icon appears and toggles the popup.

### Task 2: Reuse visual and blur components

**Files:**
- `app/Main.qml`
- `app/controlcenter.qrc`
- Root `CMakeLists.txt`

**Deliverable:** The app uses `ControlCenterPanel.qml`, image assets and shaders without importing Plasma applet types or requesting a KWin blur region. Position the popup on the screen containing the tray icon, with the rightmost capsule 13 px from the screen edge and 41 px below the top panel.

**Verification:** Capture Rebecca's desktop with the same wallpaper and compare the popup bounds, tray icon and backdrop to the current reference. Confirm the window does not reveal a static wallpaper image over foreground windows.

### Task 3: Package and document the app

**Files:**
- `app/control-center.desktop`
- `README.md`
- Create: `app/controlcenter.desktop`
- Create: `install-app.sh`
- Modify: `README.md`

**Deliverable:** Installable app binary, embedded resources, desktop launcher, and concise build/install/run/uninstall instructions. Keep `.plasmoid` packaging separate until the application path is verified.

**Verification:** Install to a user-local prefix, launch from the desktop file, confirm tray/popup operation, then remove the prior plasmoid only after the app is working.
