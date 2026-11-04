#!/usr/bin/env python3
"""Regenerate the per-card KWin blur region mask.

KWin's blur-behind API accepts a binary region, so this mask cannot encode a
progressive blur falloff. It marks the card footprints only; a future KWin
scene effect must implement any soft, live blur transition.
"""

from pathlib import Path
from math import cos, sin

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "app/control-center-blur-window-region.png"
WIDTH, HEIGHT = 304, 496
SCALE = 4

# Window coordinates match the right-aligned standalone panel.
CARDS = (
    (0, 0, 140, 62, 31, 2.0),        # Wi-Fi
    (152, 0, 140, 139, 33, 3.0),     # Media
    (0, 75, 140, 64, 32, 2.0),       # Bluetooth
    (0, 151, 140, 62, 31, 2.0),      # AirDrop
    (152, 151, 64, 64, 32, 2.0),     # Stage Manager
    (228, 151, 64, 64, 32, 2.0),     # Screen Mirroring
    (0, 228, 64, 64, 32, 2.0),       # Appearance
    (76, 228, 64, 64, 32, 2.0),      # Screenshot
    (152, 228, 140, 64, 32, 2.0),    # Focus
    (0, 303, 292, 64, 29, 3.0),      # Display
    (0, 378, 292, 64, 29, 3.0),      # Sound
    (99, 457, 94, 25, 12.5, 2.0),    # Edit Controls
)


def superellipse_points(x: float, y: float, width: float, height: float,
                        radius: float, exponent: float, scale: int):
    """Match SquircleSurface.qml's corner path at mask supersampling scale."""
    r = min(radius, width / 2, height / 2)
    power = 2 / max(2, exponent)
    steps = 64
    points = [(r, 0), (width - r, 0)]
    for i in range(steps + 1):
        t = (3.141592653589793 / 2) * i / steps
        points.append((width - r + r * (sin(t) ** power), r - r * (cos(t) ** power)))
    points.append((width, height - r))
    for i in range(steps + 1):
        t = (3.141592653589793 / 2) * i / steps
        points.append((width - r + r * (cos(t) ** power), height - r + r * (sin(t) ** power)))
    points.append((r, height))
    for i in range(steps + 1):
        t = (3.141592653589793 / 2) * i / steps
        points.append((r - r * (sin(t) ** power), height - r + r * (cos(t) ** power)))
    points.append((0, r))
    for i in range(steps + 1):
        t = (3.141592653589793 / 2) * i / steps
        points.append((r - r * (cos(t) ** power), r - r * (sin(t) ** power)))
    return [(int(round((x + px) * scale)), int(round((y + py) * scale))) for px, py in points]


def main() -> None:
    core = Image.new("L", (WIDTH * SCALE, HEIGHT * SCALE), 0)
    draw = ImageDraw.Draw(core)
    for x, y, width, height, radius, exponent in CARDS:
        draw.polygon(superellipse_points(x, y, width - 1, height - 1,
                                         radius, exponent, SCALE), fill=255)

    core = core.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)

    mask = Image.new("RGBA", (WIDTH, HEIGHT), (255, 255, 255, 0))
    mask.putalpha(core)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    mask.save(OUTPUT, optimize=True)
    print(f"Wrote {OUTPUT} ({WIDTH}x{HEIGHT}, binary card regions)")


if __name__ == "__main__":
    main()
