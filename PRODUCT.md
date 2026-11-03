# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

The owner of a KDE Plasma desktop who wants a macOS Tahoe-style Control Center.

## Product Purpose

Provide a Control Center applet whose visual rendering closely reproduces the supplied macOS Tahoe screenshot. Visual parity is the acceptance criterion for the current phase.

## Operating Context

The applet runs on the user's KDE Plasma desktop. Evaluation uses the same purple forest wallpaper and native 1920 × 1080 desktop capture as the macOS reference.

## Capabilities and Constraints

- Source is maintained in the dedicated `macos-tahoe-contro-center-kde` repository.
- Use Plasma 6 and Qt Quick/QML unless rendered evidence demonstrates that a separate application window is needed for parity.
- Keep controls visually faithful but inert until the user approves the appearance.
- Match the macOS screenshot's card shapes, individual glass surfaces, icons, typography, spacing, blur, and refraction. There is no common panel background.
- Preserve the independent squircle and capsule silhouettes and the exact supplied wallpaper behind each surface.
- Right-click context menu work is outside the current scope.

## Brand Commitments

The supplied macOS Tahoe Control Center screenshot is the binding visual reference. The liquidglass-kde-widgets project is the reference for the glass rendering technique.

## Evidence on Hand

- Original macOS reference: `/home/yohan/.codex/attachments/1836f9ae-31b7-4566-b8a8-a30513bb8be7/image-1.png` (1913 × 1074).
- User-supplied KDE rendering: `/tmp/user/1000/codex-clipboard-8d354596-dd0b-474f-8255-6b4c9d14313b.png`.
- The two captures use the same wallpaper.

## Product Principles

- Compare rendered pixels against the supplied macOS reference.
- Draw each control as an independent surface over the desktop backdrop.
- Keep the visual prototype separate from later system integration.
- Minimize disruption to the user's active desktop while capturing evidence.
