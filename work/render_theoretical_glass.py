#!/usr/bin/env python3
"""Render the Control Center over a static copy of the user's wallpaper.

All QML runs inside a private Xvfb display. This script never opens windows on
the user's desktop and never changes KWin or Plasma settings.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import pathlib
import re
import subprocess

from PIL import Image, ImageDraw, ImageFont


REPO = pathlib.Path(__file__).resolve().parents[1]
ROOT = pathlib.Path(__file__).resolve().parents[3]
QML = REPO / "work" / "preview.qml"
BUILD = REPO / "work" / "build"
RENDERER = BUILD / "controlcenter_visual_preview"
REFERENCE = ROOT / "outputs" / "control-center-reference-1920x1080.png"
DEFAULT_WALLPAPER = pathlib.Path("/home/yohan/Images/Wallpaper/4.jpg")
PANEL_CROP = (1615, 41, 1907, 525)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--wallpaper", type=pathlib.Path, default=DEFAULT_WALLPAPER)
    parser.add_argument("--scales", default="50,60,65,70,75,80,90,100",
                        help="Comma-separated theoretical refraction scales")
    parser.add_argument("--thickness", type=float,
                        help="Refraction band width in pixels; default keeps each QML surface's existing width")
    parser.add_argument("--thicknesses",
                        help="Comma-separated band widths to sweep; overrides --thickness")
    parser.add_argument("--iors", default="1.3,1.5,1.7,1.9,2.1",
                        help="Comma-separated theoretical Snell refraction indices to sweep")
    parser.add_argument("--blur", type=float, default=6.0,
                        help="Light accessibility blur radius in pixels")
    parser.add_argument("--chroma", type=float, default=0.0,
                        help="Chromatic separation; keep at zero for normal refraction")
    parser.add_argument("--profile", type=pathlib.Path,
                        help="JSON map of a surface name to a refraction scale")
    parser.add_argument("--material-sweep", type=pathlib.Path,
                        help="JSON list of named glass-material parameter sets")
    parser.add_argument("--output", type=pathlib.Path, default=ROOT / "outputs" / "theoretical-glass")
    parser.add_argument("--renderer", type=pathlib.Path, default=RENDERER)
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--settle-ms", type=int, default=1800)
    return parser.parse_args()


def build_renderer() -> None:
    subprocess.run(["cmake", "--build", str(BUILD), "--target", "controlcenter_visual_preview", "--parallel", "2"],
                   cwd=REPO, check=True)


def start_xvfb() -> tuple[subprocess.Popen[str], str]:
    proc = subprocess.Popen(
        ["Xvfb", "-displayfd", "1", "-screen", "0", "1920x1080x24", "-nolisten", "tcp", "+extension", "GLX", "+render", "-noreset"],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
    )
    assert proc.stdout is not None
    ready = proc.stdout.readline().strip()
    if not ready.isdigit() or proc.poll() is not None:
        proc.terminate()
        raise RuntimeError("Échec du démarrage de l'écran X virtuel")
    return proc, f":{ready}"


def render(renderer: pathlib.Path, env: dict[str, str], wallpaper: pathlib.Path,
           output: pathlib.Path, scale: float, thickness: float | None, blur: float,
           chroma: float, ior: float, settle_ms: int, expected_wallpaper: Image.Image,
           profile: pathlib.Path | None, material: pathlib.Path | None) -> None:
    command = [
        str(renderer), "--qml", str(QML), "--output", str(output),
        "--wallpaper", str(wallpaper), "--scale", str(scale),
        "--thickness", str(thickness if thickness is not None else -1), "--blur", str(blur),
        "--chroma", str(chroma), "--settle-ms", str(settle_ms),
        "--ior", str(ior),
    ]
    if profile:
        command += ["--profile", str(profile)]
    if material:
        command += ["--material", str(material)]
    result = subprocess.run(command, cwd=REPO, env=env, check=True, timeout=35,
                            capture_output=True, text=True)
    diagnostics = result.stdout + "\n" + result.stderr
    shader_failures = re.findall(
        r"^(?:.*(?:Failed to build graphics pipeline state|Failed to link shader program|"
        r"No GLSL shader code found|Shader baking failed).*)$",
        diagnostics, flags=re.MULTILINE,
    )
    if shader_failures:
        details = "\n".join(dict.fromkeys(shader_failures))
        raise RuntimeError(f"Le rendu a échoué malgré la capture PNG :\n{details}")
    image = Image.open(output)
    if image.size != (1920, 1080):
        raise RuntimeError(f"Taille inattendue pour {output}: {image.size}")
    probes = ((100, 100), (700, 180), (1000, 900), (1500, 800), (1900, 1000))
    max_error = max(
        max(abs(a - b) for a, b in zip(image.getpixel(point), expected_wallpaper.getpixel(point)))
        for point in probes
    )
    if max_error > 6:
        raise RuntimeError(f"Le fond du rendu ne correspond pas au wallpaper (écart max {max_error})")


def make_comparison(captures: list[tuple[str, pathlib.Path]], output: pathlib.Path) -> None:
    reference = Image.open(REFERENCE).convert("RGB").crop(PANEL_CROP)
    font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    font = ImageFont.truetype(font_path, 17)
    pad, label_height = 16, 30
    panel_width, panel_height = reference.size
    candidates_per_row = 3
    rows = (len(captures) + candidates_per_row - 1) // candidates_per_row
    row_height = panel_height + label_height + pad
    sheet = Image.new("RGB", (pad + 4 * (panel_width + pad), pad + row_height * rows), "#17151d")
    draw = ImageDraw.Draw(sheet)

    for index, (label, full_path) in enumerate(captures):
        live = Image.open(full_path).convert("RGB").crop(PANEL_CROP)
        col = index % candidates_per_row
        row = index // candidates_per_row
        y = pad + row * row_height
        reference_x = pad
        candidate_x = pad + (col + 1) * (panel_width + pad)
        if col == 0:
            draw.text((reference_x, y + 4), "macOS reference", fill="#f6f2fa", font=font)
            sheet.paste(reference, (reference_x, y + label_height))
        draw.text((candidate_x, y + 4), label, fill="#f6f2fa", font=font)
        sheet.paste(live, (candidate_x, y + label_height))
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output)


def main() -> int:
    args = parse_args()
    wallpaper = args.wallpaper.expanduser().resolve()
    renderer = args.renderer.resolve()
    profile = args.profile.expanduser().resolve() if args.profile else None
    sweep_path = args.material_sweep.expanduser().resolve() if args.material_sweep else None
    scales = [float(value.strip()) for value in args.scales.split(",") if value.strip()]
    iors = [float(value.strip()) for value in args.iors.split(",") if value.strip()]
    thicknesses = ([float(value.strip()) for value in args.thicknesses.split(",") if value.strip()]
                   if args.thicknesses else [args.thickness])
    if not scales or not iors:
        raise SystemExit("Il faut au moins une échelle et un indice de réfraction")
    if not thicknesses:
        raise SystemExit("Il faut au moins une largeur de réfraction")
    for required in (wallpaper, REFERENCE, QML):
        if not required.is_file():
            raise SystemExit(f"Fichier absent : {required}")
    if profile and not profile.is_file():
        raise SystemExit(f"Profil introuvable : {profile}")
    if sweep_path and not sweep_path.is_file():
        raise SystemExit(f"Grille matière introuvable : {sweep_path}")
    if sweep_path:
        sweep = json.loads(sweep_path.read_text())
        if not isinstance(sweep, list) or not sweep:
            raise SystemExit("La grille matière doit être une liste JSON non vide")
    else:
        sweep = [{"name": "baseline", "parameters": {}}]
    expected_wallpaper = Image.open(wallpaper).convert("RGB").resize((1920, 1080), Image.Resampling.LANCZOS)
    if not args.skip_build:
        build_renderer()
    if not renderer.is_file():
        raise SystemExit(f"Rendu compilé absent : {renderer}")

    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    batch_dir = args.output / stamp
    batch_dir.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env.pop("DISPLAY", None)
    env.pop("WAYLAND_DISPLAY", None)
    env.pop("DBUS_SESSION_BUS_ADDRESS", None)
    env.update({
        "QT_QPA_PLATFORM": "xcb",
        "QSG_RHI_BACKEND": "opengl",
        "LIBGL_ALWAYS_SOFTWARE": "1",
        "XDG_SESSION_TYPE": "x11",
    })

    xvfb, display = start_xvfb()
    env["DISPLAY"] = display
    captures: list[tuple[str, pathlib.Path]] = []
    try:
        variants = [(scale, thickness, ior, material) for material in sweep
                    for scale in scales for thickness in thicknesses for ior in iors]
        for index, (scale, thickness, ior, material_config) in enumerate(variants, 1):
            band_label = f"bande {thickness:g}px" if thickness is not None else "largeurs QML"
            label = f"{material_config.get('name', f'variante {index}')} · réfraction {scale:g}"
            thickness_label = f"{thickness:g}" if thickness is not None else "qml-default"
            filename = f"{index:02d}-{material_config.get('name', 'variant')}-scale-{scale:g}-thickness-{thickness_label}-ior-{ior:g}.png"
            path = batch_dir / filename
            print(f"Rendu {index}/{len(variants)} · {label}", flush=True)
            material_file = batch_dir / f"material-{index:02d}.json"
            material_file.write_text(json.dumps(material_config.get("parameters", {}), indent=2) + "\n")
            render(renderer, env, wallpaper, path, scale, thickness, args.blur, args.chroma, ior,
                   args.settle_ms, expected_wallpaper, profile, material_file)
            captures.append((label, path))
    finally:
        xvfb.terminate()
        try:
            xvfb.wait(timeout=3)
        except subprocess.TimeoutExpired:
            xvfb.kill()
            xvfb.wait()

    comparison = args.output / f"comparison-{stamp}.png"
    make_comparison(captures, comparison)
    (batch_dir / "parameters.json").write_text(json.dumps({
        "wallpaper": str(wallpaper), "reference": str(REFERENCE),
        "scales": scales, "thicknesses": thicknesses, "iors": iors, "blur": args.blur,
        "material_sweep": str(sweep_path) if sweep_path else None,
        "chroma": args.chroma, "profile": str(profile) if profile else None,
        "display": "private Xvfb 1920x1080; no live desktop capture",
        "images": [str(path) for _, path in captures], "comparison": str(comparison),
    }, indent=2) + "\n")
    print(f"Comparaison : {comparison}")
    print(f"Images complètes : {batch_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
