import QtQuick
import QtQuick.Window
import Tahoe.ControlCenter.Native 1.0
import "../contents/ui/components"

Window {
    id: popup

    // Keep only the 12 px reference inset on the right. The former 60 px
    // empty gutter was inherited from the plasmoid's wider popup window.
    width: 304
    // The panel is 484 px tall; keep only a 12 px transparent safety margin
    // below it so the popup does not capture clicks in an unused 60 px strip.
    height: controlCenterPanel.menuBarOnlyDetails
           ? (controlCenterPanel.menuBarDetailTarget === "Bluetooth" ? 218 : 180)
           : 496
    visible: trayController.popupVisible
    color: "transparent"
    property bool stayOpen: false
    // A managed tool window stays composited by KWin, so its live backdrop
    // blur/refracting glass effect can sample the windows beneath it.
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    title: qsTr("Control Center")

    Timer {
        id: dismissOutsideClick
        interval: 100
        onTriggered: {
            if (popup.visible && !popup.active) {
                popup.close()
            }
        }
    }

    onActiveChanged: {
        if (visible && !active && !stayOpen) {
            dismissOutsideClick.start()
        } else {
            dismissOutsideClick.stop()
        }
    }

    ControlCenterPanel {
        id: controlCenterPanel
        objectName: "controlCenterPanel"
        x: 0
        y: 0
        // LiquidGlass.qml samples Plasma's wallpaper texture, not arbitrary
        // windows under this standalone popup. KWin's class-scoped effect
        // supplies the live composited backdrop and refraction instead.
        useLiquidGlass: false
        onEditControlsRequested: {
            popup.stayOpen = true
            trayController.setPopupVisible(false)
            controlEditor.showEditor()
        }
    }

    ControlEditor {
        id: controlEditor
        objectName: "controlEditorWindow"
        onEditorClosed: popup.stayOpen = false
    }

    BlurBehindRegion {
        window: popup
        maskSource: controlCenterPanel.menuBarOnlyDetails
                    ? Qt.resolvedUrl(controlCenterPanel.menuBarDetailTarget === "Bluetooth"
                                     ? "qrc:/app/bluetooth-details-blur-window-region.png"
                                     : "qrc:/app/wifi-details-blur-window-region.png")
                    : Qt.resolvedUrl("qrc:/app/control-center-blur-window-region.png")
        alphaThreshold: 24
        // The native helper applies/removes the property on visibleChanged;
        // keep it enabled so QML binding order cannot race the QWindow map.
        enabled: true
    }

    Shortcut {
        sequence: "Escape"
        onActivated: popup.close()
    }
}
