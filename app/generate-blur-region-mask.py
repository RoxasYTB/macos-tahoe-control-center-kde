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

# Keep these footprints in sync with the default card positions in
# contents/ui/components/ControlCenterPanel.qml. A stale mask shifts KWin's
# blur/refraction away from the visible capsules, most noticeably lower down.
CARDS = (
    (17, 0, 134, 60, 30, 2.0),       # Wi-Fi
    (158, 0, 129, 131, 33, 3.0),     # Media
    (17, 70, 134, 58, 29, 2.0),      # Bluetooth
    (17, 142, 132, 59, 29.5, 2.0),   # AirDrop
    (158, 142, 63, 63, 31.5, 2.0),   # Stage Manager
    (220, 142, 65, 65, 32.5, 2.0),   # Screen Mirroring
    (17, 218, 59, 59, 29.5, 2.0),    # Appearance
    (89, 218, 59, 59, 29.5, 2.0),    # Screenshot
    (158, 218, 130, 59, 29.5, 2.0), # Focus
    (16, 291, 271, 63, 29, 3.0),    # Display
    (16, 364, 271, 63, 29, 3.0),    # Sound
    (116, 438, 100, 23, 11.5, 2.0), # Edit Controls
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
