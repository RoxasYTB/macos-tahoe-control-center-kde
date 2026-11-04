# Tahoe Control Center for KDE — standalone app

A visual-first KDE desktop application based on the supplied macOS Tahoe Control Center reference. A small C++ tray host opens the QML-rendered Control Center as a native popup window; this avoids Plasma applet popup anchoring. The layout is still being refined. Wi-Fi and Bluetooth status and radio controls use NetworkManager and BlueZ, while the detail popovers show available networks and devices from those services.

The retired Plasma applet is no longer packaged. The standalone app retains the GPL-3.0 LiquidGlass component from [liquidglass-kde-widgets](https://github.com/jaxparrow07/liquidglass-kde-widgets) in its source bundle. See [`NOTICE`](NOTICE) for the exact source revision.

## Build and run the application

Requires Qt 6.6+, Qt Quick, Qt Widgets, KF6 WindowSystem development files, CMake, a C++ compiler and KDE Plasma.

Build and launch a temporary live preview:

```sh
./build-app.sh
./.build/app/tahoe-control-center --show
```

Run hidden in the system tray:

```sh
./.build/app/tahoe-control-center
```

Install into `~/.local`:

```sh
./install-app.sh
```

The installed launcher is `~/.local/bin/tahoe-control-center`; its desktop entry is `~/.local/share/applications/control-center.desktop`. The installer also adds a user-session autostart entry so the tray icon is available after login. Click it to open or close the popup. Escape or clicking outside closes it.

To remove the user-local app, stop it and remove `~/.local/bin/tahoe-control-center`, `~/.local/share/applications/control-center.desktop`, `~/.local/share/icons/hicolor/512x512/apps/control-centre-iconscout-white.png`, and `~/.config/autostart/tahoe-control-center.desktop` (or the matching path under `XDG_CONFIG_HOME`).

## Live glass rendering

The standalone app sends KWin a binary mask made from the individual card
footprints. It does not draw a second QML glass effect or bake a wallpaper into
the popup. With this project's Acrylic Glass KWin effect enabled, the effect
samples the current composited scene behind the popup on each frame, applies a
subtle blur that fades in over 6 px at each card edge, and refracts those live
pixels. The mask keeps the spaces between cards clear. The app's blur region by
itself remains binary; progressive falloff and refraction are provided by the
KWin effect, not by a cached screenshot or by the app's QML.

Each card uses a subtle neutral white veil to preserve legibility over dark
live content. It does not impose a pink/purple tint; the sampled application
colors remain visible through the compositor glass.

## Visual scope

- Wi-Fi and Bluetooth status, radio toggles, and detail lists use the host's NetworkManager and BlueZ state. Media buttons send commands to an available MPRIS player; the displayed "Not Playing" label remains reference content.
- AirDrop and Focus keep their macOS labels and render disabled.
- Sound controls the default sink through `pactl`; Screenshot launches Spectacle; Appearance requests the KDE light/dark color scheme. Display brightness is disabled when no supported backlight control is available. Remaining controls are visual only.
- The popup has no shared outer surface; each control is drawn as its own independent card.
- Symbols use the bundled Cupertino Icons font directly wherever a glyph matches the reference. Project SVGs cover Tahoe-specific symbols; the screenshot glyph adapts Cupertino's `camera_viewfinder` SVG to the reference. Their shapes and colors do not depend on the installed KDE icon theme. Source and license details are in [`NOTICE`](NOTICE) and `contents/ui/components/icons/CUPERTINO-ICONS-LICENSE.txt`.
- Cupertino Icons are Flutter's independently licensed, Apple-styled icon set, not official Apple SF Symbols. The font is from [Flutter's Cupertino Icons package](https://github.com/flutter/packages/tree/main/third_party/packages/cupertino_icons), version 2.0.0, under MIT.
- Official Apple SF Symbols and Apple Design Resources are not bundled. Apple's [Apple Design Resources License](https://developer.apple.com/support/downloads/terms/apple-design-resources/Apple-Design-Resources-License-20230621-English.pdf) limits them to UI mockups for software running only on Apple operating systems and prohibits embedding them in software. To keep this KDE app distributable, its close-match glyphs use the MIT Cupertino set and project-drawn SVGs.
- Each card has its own translucent QML surface and area in the KWin blur mask; the compositor provides the live backdrop and the gaps between cards remain clear. The companion KWin effect fades blur in over 6 px and applies refraction to the current scene.
