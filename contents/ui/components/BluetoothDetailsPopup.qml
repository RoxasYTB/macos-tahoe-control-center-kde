import QtQuick
import QtQuick.Controls

pragma ComponentBehavior: Bound

Popup {
    id: root
    property Item ownerItem: null
    property Item backdropOverride: null
    property bool useLiquidGlass: false
    property var controlController: null

    function deviceIcon(deviceName) {
        const name = deviceName.toLowerCase()
        if (name.indexOf("head") >= 0 || name.indexOf("earbud") >= 0
                || name.indexOf("airpod") >= 0 || name.indexOf("rebel") >= 0)
            return "cupertino-font-headphones"
        if (name.indexOf("phone") >= 0 || name.indexOf("iphone") >= 0
                || name.indexOf("bv5300") >= 0)
            return "cupertino-font-phone_fill"
        if (name.indexOf("speaker") >= 0 || name.indexOf("sound") >= 0
                || name.indexOf("flow") >= 0)
            return "cupertino-font-speaker_2_fill"
        if (name.indexOf("keyboard") >= 0) return "cupertino-font-keyboard"
        if (name.indexOf("mouse") >= 0 || name.indexOf("trackpad") >= 0
                || name.indexOf("mx ") >= 0)
            return "cupertino-font-cursor_rays"
        return "cupertino-font-desktopcomputer"
    }

    parent: ownerItem
    x: -11
    y: -4
    width: 308
    height: 214
    padding: 0
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    onOpened: if (controlController) controlController.refreshBluetoothDevices()

    background: GlassCard {
        useLiquidGlass: root.useLiquidGlass
        backdropOverride: root.backdropOverride
        cornerRadius: 20
        roundness: 2.6
        fillColor: Qt.rgba(1, 1, 1, 0.13)
        borderColor: Qt.rgba(1, 1, 1, 0.34)
        glassBlurRadius: 10
        glassEdgeRimStrength: 0.20
    }

    contentItem: Item {
        Row {
            x: 14; y: 8; width: parent.width - 28; height: 32
            Text {
                width: parent.width - bluetoothPower.width; height: parent.height
                text: qsTr("Bluetooth"); color: "#fffaff"
                font.family: "SF Pro Text"; font.pixelSize: 14; font.weight: Font.DemiBold
                verticalAlignment: Text.AlignVCenter
            }
            Switch {
                id: bluetoothPower
                width: 48; height: 30; anchors.verticalCenter: parent.verticalCenter
                checked: root.controlController && root.controlController.bluetoothAvailable
                         && root.controlController.bluetoothEnabled
                enabled: root.controlController !== null && root.controlController.bluetoothAvailable
                onClicked: if (root.controlController) root.controlController.toggleBluetooth()
                Accessible.name: qsTr("Bluetooth power")
            }
        }

        Column {
            x: 12; y: 45; width: parent.width - 24
            Repeater {
                model: root.controlController ? root.controlController.bluetoothDevices.slice(0, 4) : []
                delegate: Item {
                    required property var modelData
                    width: parent.width; height: 32
                    Row {
                        anchors.fill: parent; spacing: 9
                        Rectangle {
                            width: 24; height: 24; anchors.verticalCenter: parent.verticalCenter; radius: 12
                            color: "#b9a6d7"
                            MacIcon {
                                anchors.centerIn: parent
                                width: 14
                                height: 14
                                iconName: root.deviceIcon(modelData.name)
                                glyphColor: "#ffffff"
                            }
                        }
                        Text {
                            width: parent.width - 38; height: parent.height
                            text: modelData.name
                            color: root.controlController && root.controlController.bluetoothAvailable
                                   && root.controlController.bluetoothEnabled && modelData.connected
                                   ? "#fffaff" : Qt.rgba(1, 1, 1, 0.68)
                            font.family: "SF Pro Text"; font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
                        }
                    }
                    TapHandler {
                        enabled: root.controlController !== null
                                 && root.controlController.bluetoothAvailable
                                 && root.controlController.bluetoothEnabled
                        onTapped: root.controlController.toggleBluetoothDevice(
                                      modelData.address, modelData.connected)
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: modelData.name + (modelData.connected ? qsTr(", connected") : qsTr(", disconnected"))
                }
            }
            Text {
                width: parent.width; height: 64
                visible: !root.controlController || !root.controlController.bluetoothAvailable
                         || root.controlController.bluetoothDevices.length === 0
                text: !root.controlController || !root.controlController.bluetoothAvailable
                      ? qsTr("Unavailable")
                      : !root.controlController.bluetoothEnabled
                        ? qsTr("Bluetooth is Off") : qsTr("No paired devices")
                color: Qt.rgba(1, 1, 1, 0.72)
                font.family: "SF Pro Text"; font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            x: 14; y: parent.height - 34; width: parent.width - 28; height: 1
            color: Qt.rgba(1, 1, 1, 0.13)
        }
        Item {
            x: 14; y: parent.height - 32; width: parent.width - 28; height: 26
            Text {
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Bluetooth Settings…"); color: "#fffaff"
                font.family: "SF Pro Text"; font.pixelSize: 12
            }
            TapHandler {
                enabled: root.controlController !== null
                onTapped: root.controlController.openBluetoothSettings()
            }
        }
    }
}
