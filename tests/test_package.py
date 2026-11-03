import json
import re
import subprocess
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_plasma_package_metadata():
    metadata = json.loads((ROOT / "metadata.json").read_text(encoding="utf-8"))
    assert metadata["KPlugin"]["Id"] == "org.kde.mac-tahoe-liquid-kde.controlcenter"
    assert metadata["KPackageStructure"] == "Plasma/Applet"


def test_popup_is_transparent_and_visual_only():
    qml = (ROOT / "contents/ui/main.qml").read_text(encoding="utf-8")
    panel = (ROOT / "contents/ui/components/ControlCenterPanel.qml").read_text(encoding="utf-8")
    assert "PlasmaCore.Dialog.NoBackground" in qml
    assert "Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground" in qml
    assert "PlasmaCore.AppletPopup" in qml
    assert "LiquidGlass" not in panel
    assert "PlasmaNM." not in qml
    assert "BluezQt." not in qml
    assert "Mpris." not in qml
    assert 'title: "AirDrop"' in panel
    assert 'title: "Focus"' in panel


def test_panel_has_reference_geometry_and_independent_glass_cards():
    qml = (ROOT / "contents/ui/components/ControlCenterPanel.qml").read_text(encoding="utf-8")
    assert re.search(r"width:\s*292\s*\n\s*height:\s*486", qml)
    assert qml.count("QuickTile {") >= 8
    assert qml.count("GlassCard {") >= 2
    assert qml.count("SliderCard {") == 2
    assert "Rectangle {" not in qml
    assert 'x: 152; y: 0; width: 140; height: 139' in qml
    assert 'x: 0; y: 303; width: 292; height: 64' in qml
    assert 'x: 0; y: 380; width: 292; height: 64' in qml


def test_reference_icons_are_authored_svg_assets():
    icons = ROOT / "contents/ui/components/icons"
    expected = {
        "wifi-blue", "bluetooth-blue", "airdrop-muted", "stage-manager",
        "screen-mirroring", "appearance", "screenshot", "moon",
        "brightness-low", "brightness-high", "volume-low", "volume-high",
        "audio-output", "media-previous", "media-play", "media-next",
        "control-center-white",
    }
    assert {path.stem for path in icons.glob("*.svg")} >= expected


def test_glass_uses_superellipse_and_gpl_source_notice():
    card = (ROOT / "contents/ui/components/GlassCard.qml").read_text(encoding="utf-8")
    shader = (ROOT / "contents/ui/components/shaders/liquidglass.frag").read_text(encoding="utf-8")
    notice = (ROOT / "NOTICE").read_text(encoding="utf-8")
    assert "property real roundness: 7.5" in card
    assert "superellipse" in shader.lower() or "squircle" in shader.lower()
    assert "0d1b9fe34ca3d21fc6f31b599990490d637ce8f8" in notice
    assert (ROOT / "LICENSE").is_file()


def test_package_script_creates_root_metadata_and_required_shader_assets(tmp_path):
    subprocess.run([str(ROOT / "package.sh")], cwd=ROOT, check=True, capture_output=True, text=True)
    package = ROOT / "dist/control-center-0.1.0.plasmoid"
    assert package.is_file()
    with zipfile.ZipFile(package) as archive:
        names = set(archive.namelist())
    assert "metadata.json" in names
    assert "contents/ui/main.qml" in names
    assert "contents/ui/components/shaders/liquidglass.frag.qsb" in names
    assert "contents/ui/components/shaders/blur_v.frag.qsb" in names
