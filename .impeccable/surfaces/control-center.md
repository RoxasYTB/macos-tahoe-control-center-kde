# Control Center surface

- Mode: Operate
- Product task: visually reproduce the supplied macOS Tahoe Control Center on KDE Plasma.
- Success: at 1920×1080, each card and symbol occupies the same position, size and silhouette as the reference; the same wallpaper remains visible in the gaps.
- Required content: Wi-Fi, Bluetooth, AirDrop, media tile, Stage Manager, Screen Mirroring, Appearance, Screenshot, Focus, Display, Sound, Edit Controls.
- Current pass: shape, icon and layout parity. Leave all controls inert. Defer Liquid Glass blur/refraction tuning.
- Do not draw a common panel background. The popup itself must be transparent.
- Reference: `work/control-center-target.png`, cropped from the user supplied macOS screenshot; full reference is 1913×1074.
- The user confirmed that Rebecca and the reference use the same wallpaper.
- Main card sizes (logical px): network tiles 140×62; media 140×139; round controls 64×64; Focus 140×64; sliders 292×64; footer capsule 94×26. Gaps: 12–13 px. Popup: 292×486.
