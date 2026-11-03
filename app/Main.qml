import QtQuick
import QtQuick.Window
import "../contents/ui/components"

Window {
    id: popup

    width: 365
    height: 544
    visible: false
    color: "transparent"
    flags: Qt.Popup | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    title: qsTr("Control Center")

    Image {
        id: desktopBackdrop
        anchors.fill: parent
        visible: false
        source: trayController.backdropUrl
        sourceSize: Qt.size(width, height)
        cache: false
        asynchronous: false
    }

    ControlCenterPanel {
        x: 60
        y: 0
        backdropOverride: desktopBackdrop
        useLiquidGlass: true
    }

    Shortcut {
        sequence: "Escape"
        onActivated: popup.close()
    }
}
