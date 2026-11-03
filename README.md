# Tahoe Control Center for KDE Plasma

A visual-first, standalone Plasma 6 applet built against the supplied macOS Tahoe Control Center reference. Geometry and icon placement are being iterated against the screenshot; the current rendering is not yet a 1:1 match. Device actions remain inert. The LiquidGlass renderer is in use, but its blur and refraction still need tuning against the reference.

The glass renderer adapts the GPL-3.0 LiquidGlass component from [liquidglass-kde-widgets](https://github.com/jaxparrow07/liquidglass-kde-widgets). See [`NOTICE`](NOTICE) for the exact source revision.

## Build

Requires Plasma 6, Qt 6 and `kpackagetool6`. To build the installable package:

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
- Each card uses its own LiquidGlass surface. The current blur and refraction output remains visibly different from the reference.
