import re
import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_popup_is_transparent_and_visual_only():
    qml = (ROOT / "app/Main.qml").read_text(encoding="utf-8")
    panel = (ROOT / "contents/ui/components/ControlCenterPanel.qml").read_text(encoding="utf-8")
    assert 'color: "transparent"' in qml
    assert "BlurBehindRegion" in qml
    assert "maskSource:" in qml
    assert "useLiquidGlass: false" in qml
    assert 'title: "AirDrop"' in panel
    assert 'title: "Focus"' in panel
    def tile(name):
        title = panel.index(f'title: "{name}"')
        start = panel.rfind("QuickTile {", 0, title)
        end = panel.find("\n    }", title)
        return panel[start:end]

    airdrop = tile("AirDrop")
    focus = tile("Focus")
    assert "disabled: true" in airdrop
    assert "disabled: true" in focus


def test_panel_has_reference_geometry_and_independent_glass_cards():
    qml = (ROOT / "contents/ui/components/ControlCenterPanel.qml").read_text(encoding="utf-8")
    assert re.search(r"width:\s*292\s*\n\s*height:\s*484", qml)
    assert qml.count("QuickTile {") >= 8
    assert qml.count("GlassCard {") >= 2
    assert qml.count("SliderCard {") == 3
    assert "Rectangle {" not in qml
    assert 'x: 158; y: 0; width: 129; height: 131' in qml
    assert 'x: 16; y: 291; width: 271; height: 63' in qml
    assert 'x: 16; y: 364; width: 271; height: 63' in qml


def test_reference_icons_are_authored_svg_assets():
    icons = ROOT / "contents/ui/components/icons"
    expected = {
        "wifi-blue", "bluetooth-blue", "airdrop-muted", "stage-manager",
        "screen-mirroring", "appearance", "screenshot", "moon",
        "brightness-low", "brightness-high", "volume-low", "volume-high",
        "audio-output",
        "control-center-white",
    }
    assert {path.stem for path in icons.glob("*.svg")} >= expected


def test_glass_uses_superellipse_and_gpl_source_notice():
    card = (ROOT / "contents/ui/components/GlassCard.qml").read_text(encoding="utf-8")
    shader = (ROOT / "contents/ui/components/shaders/liquidglass.frag").read_text(encoding="utf-8")
    notice = (ROOT / "NOTICE").read_text(encoding="utf-8")
    assert "property real roundness: 2.5" in card
    assert "superellipse" in shader.lower() or "squircle" in shader.lower()
    assert "0d1b9fe34ca3d21fc6f31b599990490d637ce8f8" in notice
    assert (ROOT / "LICENSE").is_file()


def test_standalone_control_center_is_managed_and_dismisses_outside():
    qml = (ROOT / "app" / "Main.qml").read_text(encoding="utf-8")
    assert "Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint" in qml
    assert "Qt.Popup |" not in qml
    assert "onActiveChanged" in qml
    assert "if (popup.visible && !popup.active)" in qml


def test_standalone_detail_menus_use_their_own_blur_masks():
    qml = (ROOT / "app" / "Main.qml").read_text(encoding="utf-8")
    resources = (ROOT / "app" / "controlcenter.qrc").read_text(encoding="utf-8")
    wifi_popup = (ROOT / "contents/ui/components/ControlDetailsPopup.qml").read_text(encoding="utf-8")
    bluetooth_popup = (ROOT / "contents/ui/components/BluetoothDetailsPopup.qml").read_text(encoding="utf-8")
    assert 'controlCenterPanel.detailsOpen' in qml
    assert 'controlCenterPanel.menuBarDetailTarget === "Bluetooth"' in qml
    assert 'qrc:/app/wifi-details-blur-window-region.png' in qml
    assert 'qrc:/app/bluetooth-details-blur-window-region.png' in qml
    assert 'qrc:/app/control-center-blur-window-region.png' in qml
    assert 'alias="app/wifi-details-blur-window-region.png"' in resources
    assert 'alias="app/bluetooth-details-blur-window-region.png"' in resources
    assert 'fillColor: Qt.rgba(0, 0, 0, 0.22)' in wifi_popup
    assert 'fillColor: Qt.rgba(0, 0, 0, 0.22)' in bluetooth_popup
    assert 'popupType: Popup.Item' in wifi_popup
    assert 'popupType: Popup.Item' in bluetooth_popup
    wifi_mask = (ROOT / "app" / "wifi-details-blur-window-region.png").read_bytes()
    bluetooth_mask = (ROOT / "app" / "bluetooth-details-blur-window-region.png").read_bytes()
    assert struct.unpack(">II", wifi_mask[16:24]) == (304, 180)
    assert struct.unpack(">II", bluetooth_mask[16:24]) == (304, 218)


def test_removing_a_default_control_does_not_break_reference_layout():
    qml = (ROOT / "contents/ui/components/ControlCenterPanel.qml").read_text(encoding="utf-8")
    assert "followsDefaultOrder(savedControlLayout.controlCenterItems" in qml
    assert "const expected = defaults.filter(name => items.indexOf(name) >= 0)" in qml
