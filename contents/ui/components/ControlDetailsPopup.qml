import QtQuick
import QtQuick.Controls

pragma ComponentBehavior: Bound

Popup {
    id: root

    property Item ownerItem: null
    property Item backdropOverride: null
    property bool useLiquidGlass: false
    property var controlController: null
    property bool expandedNetworks: false

    parent: ownerItem
    // Keep details in the Control Center's scene/window so its KWin glass
    // effect and per-window blur region apply to these submenus too.
    popupType: Popup.Item
    x: 0
    y: 0
    width: 304
    height: expandedNetworks && controlController
            ? 176 + Math.min(5, controlController.wifiOtherNetworks.length) * 27
            : 176
    padding: 0
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    onOpened: {
        expandedNetworks = false
        if (controlController) controlController.refreshWifiNetworks()
    }

    background: GlassCard {
        useLiquidGlass: root.useLiquidGlass
        backdropOverride: root.backdropOverride
        cornerRadius: 20
        roundness: 2.6
        // A neutral charcoal wash lets the live wallpaper supply the hue
        // while keeping bright content behind the glass readable.
        fillColor: Qt.rgba(0, 0, 0, 0.22)
        borderColor: Qt.rgba(1, 1, 1, 0.34)
        glassBlurRadius: 10
        glassEdgeRimStrength: 0.20
    }

    contentItem: Item {
        Row {
            x: 14
            y: 8
            width: parent.width - 28
            height: 32
            spacing: 0

            Text {
                width: parent.width - wifiPower.width
                height: parent.height
                text: qsTr("Wi-Fi")
                color: "#fffaff"
                font.family: "SF Pro Text"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                verticalAlignment: Text.AlignVCenter
            }

            Switch {
                id: wifiPower
                width: 48
                height: 30
                anchors.verticalCenter: parent.verticalCenter
                // Keep unavailable hardware visibly off and prevent a toggle
                // from being offered when NetworkManager has no Wi-Fi device.
                checked: root.controlController && root.controlController.wifiAvailable
                         && root.controlController.wifiEnabled
                enabled: root.controlController !== null && root.controlController.wifiAvailable
                onClicked: if (root.controlController) root.controlController.toggleWifi()
                Accessible.name: qsTr("Wi-Fi power")
                indicator: Rectangle {
                    implicitWidth: 48
                    implicitHeight: 28
                    x: wifiPower.leftPadding
                    y: (wifiPower.height - height) / 2
                    radius: height / 2
                    color: wifiPower.checked ? "#0a84ff" : Qt.rgba(1, 1, 1, 0.22)
                    opacity: wifiPower.enabled ? 1 : 0.55

                    Rectangle {
                        width: 24
                        height: 24
                        x: wifiPower.checked ? parent.width - width - 2 : 2
                        y: 2
                        radius: width / 2
                        color: "#ffffff"
                        Behavior on x { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }

        Text {
            x: 14
            y: 49
            text: qsTr("Known Network")
            color: Qt.rgba(1, 1, 1, 0.73)
            font.family: "SF Pro Text"
            font.pixelSize: 11
            font.weight: Font.DemiBold
        }

        Item {
            x: 12
            y: 68
            width: parent.width - 24
            height: 36

            Rectangle {
                x: 0
                y: 3
                width: 24
                height: 24
                radius: 12
                color: "#ffffff"
                MacIcon {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    iconName: "wifi-blue"
                    glyphColor: "#007aff"
                }
            }

            Text {
                x: 31
                y: 0
                width: parent.width - 60
                height: parent.height
                text: !root.controlController || !root.controlController.wifiAvailable
                      ? qsTr("Unavailable")
                      : !root.controlController.wifiEnabled ? qsTr("Off")
                      : root.controlController.wifiNetworkName.length
                        ? root.controlController.wifiNetworkName : qsTr("Not Connected")
                color: "#fffaff"
                font.family: "SF Pro Text"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            MacIcon {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                height: 16
                visible: root.controlController && root.controlController.wifiAvailable
                         && root.controlController.wifiNetworkSecured
                iconName: "cupertino-font-lock_fill"
                glyphColor: Qt.rgba(1, 1, 1, 0.78)
                Accessible.name: qsTr("Secured network")
            }
        }

        Rectangle {
            x: 14
            y: 107
            width: parent.width - 28
            height: 1
            color: Qt.rgba(1, 1, 1, 0.13)
        }

        Item {
            id: otherNetworksRow
            x: 14
            y: 111
            width: parent.width - 28
            height: 31

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Other Networks")
                color: "#fffaff"
                font.family: "SF Pro Text"
                font.pixelSize: 12
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.expandedNetworks ? "⌄" : "›"
                color: Qt.rgba(1, 1, 1, 0.7)
                font.pixelSize: 17
            }

            TapHandler {
                enabled: root.controlController && root.controlController.wifiAvailable
                onTapped: {
                    root.expandedNetworks = !root.expandedNetworks
                    if (root.expandedNetworks && root.controlController)
                        root.controlController.refreshWifiNetworks()
                }
            }
            Accessible.role: Accessible.Button
            Accessible.name: qsTr("Other Networks")
        }

        Column {
            x: 18
            y: 143
            width: parent.width - 36
            spacing: 0
            visible: root.expandedNetworks && root.controlController
            Repeater {
                model: root.controlController ? root.controlController.wifiOtherNetworks.slice(0, 5) : []
                delegate: Item {
                    id: networkRow
                    required property string modelData
                    width: parent.width
                    height: 27

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.10)
                        visible: networkHover.hovered || parent.activeFocus
                    }
                    Text {
                        anchors.fill: parent
                        leftPadding: 4
                        text: networkRow.modelData
                        color: Qt.rgba(1, 1, 1, 0.88)
                        font.family: "SF Pro Text"
                        font.pixelSize: 11
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    HoverHandler { id: networkHover }
                    TapHandler {
                        enabled: root.controlController && root.controlController.wifiAvailable
                                 && root.controlController.wifiEnabled
                        onTapped: root.controlController.connectWifiNetwork(networkRow.modelData)
                    }
                    activeFocusOnTab: root.controlController && root.controlController.wifiAvailable
                                      && root.controlController.wifiEnabled
                    Keys.onReturnPressed: function(event) {
                        if (!activeFocusOnTab) return
                        root.controlController.connectWifiNetwork(networkRow.modelData)
                        event.accepted = true
                    }
                    Keys.onEnterPressed: function(event) {
                        if (!activeFocusOnTab) return
                        root.controlController.connectWifiNetwork(networkRow.modelData)
                        event.accepted = true
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Connect to %1").arg(networkRow.modelData)
                }
            }
        }

        Rectangle {
            x: 14
            y: root.expandedNetworks ? parent.height - 31 : 145
            width: parent.width - 28
            height: 1
            color: Qt.rgba(1, 1, 1, 0.13)
        }

        Item {
            x: 14
            y: root.expandedNetworks ? parent.height - 29 : 147
            width: parent.width - 28
            height: 25

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Wi-Fi Settings…")
                color: "#fffaff"
                font.family: "SF Pro Text"
                font.pixelSize: 12
            }
            TapHandler {
                enabled: root.controlController !== null
                onTapped: root.controlController.openWifiSettings()
            }
        }
    }
}
