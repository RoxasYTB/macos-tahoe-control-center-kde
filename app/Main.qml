import QtQuick
import QtQuick.Window
import Tahoe.ControlCenter.Native 1.0
import "../contents/ui/components"

Window {
    id: popup

    // Keep only the 12 px reference inset on the right. The former 60 px
    // empty gutter was inherited from the plasmoid's wider popup window.
    width: 304
    height: 544
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
        x: 0
        y: 0
        useLiquidGlass: false
    }

    BlurBehindRegion {
        window: popup
        maskSource: Qt.resolvedUrl("qrc:/app/control-center-blur-window-region.png")
        alphaThreshold: 8
        // The native helper applies/removes the property on visibleChanged;
        // keep it enabled so QML binding order cannot race the QWindow map.
        enabled: true
    }

    Shortcut {
        sequence: "Escape"
        onActivated: popup.close()
    }
}
