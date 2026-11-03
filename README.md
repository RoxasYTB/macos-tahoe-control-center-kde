# Tahoe Control Center for KDE

A visual-first KDE desktop application based on the supplied macOS Tahoe Control Center reference. A small C++ tray host opens the QML-rendered Control Center as a native popup window; this avoids Plasma applet popup anchoring. Geometry and icon placement are still being compared against the reference, and device actions remain inert.

The legacy plasmoid retains the GPL-3.0 LiquidGlass component from [liquidglass-kde-widgets](https://github.com/jaxparrow07/liquidglass-kde-widgets). See [`NOTICE`](NOTICE) for the exact source revision.

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

The `.plasmoid` packaging command below remains for compatibility with older installations; the standalone application is the current runtime path.

## Build

The standalone app sends KWin a binary mask made from the individual card
footprints. It does not draw a second QML glass effect or bake a wallpaper into
the popup. With this project's Acrylic Glass KWin effect enabled, the effect
samples the current composited scene behind the popup on each frame, applies a
subtle blur that fades in over 6 px at each card edge, and refracts those live
pixels. The mask keeps the spaces between cards clear. The app's blur region by
itself remains binary; progressive falloff and refraction are provided by the
KWin effect, not by a cached screenshot or by the app's QML.

The Control Center's QML card fills are transparent, so the effect does not add
a pink panel tint over applications such as Discord. The effect's optional
gradient tint remains a separate user setting and is off in the Tahoe preset.

To build the legacy applet package:

```sh
./package.sh
```

The resulting `.plasmoid` is written under `dist/`. Installing it is not part of the package command.

## Visual scope

- Wi-Fi, Bluetooth and media states are static reference content.
- AirDrop and Focus keep their macOS labels and render disabled.
- Display, Sound, Screenshot and other controls are visual only.
- The popup has no shared outer surface; each control is drawn as its own independent card.
- Symbols use the bundled Cupertino Icons font directly wherever a glyph matches the reference. Project SVGs cover Tahoe-specific symbols; the screenshot glyph adapts Cupertino's `camera_viewfinder` SVG to the reference. Their shapes and colors do not depend on the installed KDE icon theme. Source and license details are in [`NOTICE`](NOTICE) and `contents/ui/components/icons/CUPERTINO-ICONS-LICENSE.txt`.
- Cupertino Icons are Flutter's independently licensed, Apple-styled icon set, not official Apple SF Symbols. The font is from [Flutter's Cupertino Icons package](https://github.com/flutter/packages/tree/main/third_party/packages/cupertino_icons), version 2.0.0, under MIT.
- Official Apple SF Symbols and Apple Design Resources are not bundled. Apple's [Apple Design Resources License](https://developer.apple.com/support/downloads/terms/apple-design-resources/Apple-Design-Resources-License-20230621-English.pdf) limits them to UI mockups for software running only on Apple operating systems and prohibits embedding them in software. To keep this KDE applet distributable, its close-match glyphs use the MIT Cupertino set and project-drawn SVGs.
- Each card has a transparent QML surface and its own area in the KWin blur mask; the compositor provides the live backdrop and the gaps between cards remain clear. The companion KWin effect fades blur in over 6 px and applies refraction to the current scene.
