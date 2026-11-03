#!/usr/bin/env python3
"""Regenerate the per-card KWin blur region mask.

KWin's blur-behind API accepts a binary region, so this mask cannot encode a
progressive blur falloff. It marks the card footprints only; a future KWin
scene effect must implement any soft, live blur transition.
"""

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "app/control-center-blur-window-region.png"
WIDTH, HEIGHT = 304, 544
SCALE = 4

# Window coordinates match the right-aligned standalone panel.
CARDS = (
    (0, 0, 140, 62, 31),        # Wi-Fi
    (152, 0, 140, 139, 33),     # Media
    (0, 75, 140, 64, 32),       # Bluetooth
    (0, 151, 140, 62, 31),      # AirDrop
    (152, 151, 64, 64, 32),     # Stage Manager
    (228, 151, 64, 64, 32),     # Screen Mirroring
    (0, 228, 64, 64, 32),       # Appearance
    (76, 228, 64, 64, 32),      # Screenshot
    (152, 228, 140, 64, 32),    # Focus
    (0, 303, 292, 64, 29),      # Display
    (0, 378, 292, 64, 29),      # Sound
    (99, 457, 94, 25, 12),      # Edit Controls
)


def main() -> None:
    core = Image.new("L", (WIDTH * SCALE, HEIGHT * SCALE), 0)
    draw = ImageDraw.Draw(core)
    for x, y, width, height, radius in CARDS:
        box = tuple(int(value * SCALE) for value in
                    (x, y, x + width - 1, y + height - 1))
        draw.rounded_rectangle(box, radius=radius * SCALE, fill=255)

    core = core.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)

    mask = Image.new("RGBA", (WIDTH, HEIGHT), (255, 255, 255, 0))
    mask.putalpha(core)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    mask.save(OUTPUT, optimize=True)
    print(f"Wrote {OUTPUT} ({WIDTH}x{HEIGHT}, binary card regions)")


if __name__ == "__main__":
    main()
