import QtQuick
import QtQuick.Window
import Tahoe.ControlCenter.Native 1.0
import "../contents/ui/components"

Window {
    id: popup

    width: 365
    height: 544
    visible: trayController.popupVisible
    color: "transparent"
    flags: Qt.Popup | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    title: qsTr("Control Center")

    ControlCenterPanel {
        x: 60
        y: 0
        useLiquidGlass: false
    }

    BlurBehindRegion {
        window: popup
        maskSource: Qt.resolvedUrl("../contents/ui/components/icons/control-center-blur-window-region.png")
        alphaThreshold: 8
        enabled: popup.visible
    }

    Shortcut {
        sequence: "Escape"
        onActivated: popup.close()
    }
}
