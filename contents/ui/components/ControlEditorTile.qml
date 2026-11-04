import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property var entry
    property string iconName: ""
    property string statusText: ""
    signal addRequested(string controlName)

    readonly property bool isPill: entry.shape === "pill"
    readonly property bool isLarge: entry.shape === "large"
    readonly property real surfaceHeight: isLarge ? 138 : 62
    readonly property string pillTitle: entry.name === "Tile Windows Left & Right" ? qsTr("Left & Right")
        : entry.name === "Run Shortcut" ? qsTr("Shortcut") : entry.name

    width: entry.shape === "circle" ? 62 : 138
    height: surfaceHeight + 36

    Column {
        anchors.fill: parent
        spacing: 5

        Item {
            width: root.width
            height: root.surfaceHeight

            Rectangle {
                id: surface
                anchors.fill: parent
                radius: root.isPill ? height / 2 : (root.entry.shape === "circle" ? width / 2 : 28)
                color: root.isLarge ? "#957b1288" :
                    root.entry.category === "Connectivity" ? "#804b2872" :
                    root.entry.category === "Display & Brightness" ? "#8b6d2294" :
                    root.entry.category === "Fast User Switching" ? "#8c36558c" : "#98631788"
                border.color: "#63d3a8eb"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: root.isPill ? 8 : 0
                    anchors.rightMargin: root.isPill ? 7 : 0
                    spacing: 7
                    visible: root.isPill

                    Item {
                        Layout.preferredWidth: 37
                        Layout.preferredHeight: 37

                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: ["Wi-Fi", "Bluetooth"].indexOf(root.entry.name) >= 0 ? "white"
                                : root.entry.name === "AirDrop" ? "#405d6876" : "transparent"
                        }

                        MacIcon {
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            iconName: root.iconName
                            glyphColor: ["Wi-Fi", "Bluetooth"].indexOf(root.entry.name) >= 0 ? "#1687f8" : "white"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: root.pillTitle
                            color: "white"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: ["Wi-Fi", "Bluetooth", "AirDrop", "Battery"].indexOf(root.entry.name) >= 0
                            text: root.statusText
                            color: "#e4dbea"
                            font.pixelSize: 9
                            elide: Text.ElideRight
                        }
                    }
                }

                MacIcon {
                    anchors.centerIn: parent
                    width: 25
                    height: 25
                    visible: !root.isPill && !root.isLarge
                    iconName: root.iconName
                    glyphColor: "white"
                }

                MacIcon {
                    anchors.horizontalCenter: root.entry.name === "Scene or Accessory" ? parent.horizontalCenter : undefined
                    anchors.left: root.entry.name === "Start Screen Saver" ? parent.left : undefined
                    anchors.leftMargin: 16
                    anchors.top: parent.top
                    anchors.topMargin: 16
                    width: 28
                    height: 28
                    visible: root.isLarge
                    iconName: root.iconName
                    glyphColor: "white"
                }

                Text {
                    visible: root.entry.name === "Start Screen Saver"
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 13
                    width: parent.width - 28
                    text: qsTr("Start Screen Saver")
                    color: "white"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 12
                    spacing: 7
                    visible: root.entry.name === "Scene or Accessory"

                    Rectangle { width: 36; height: 8; radius: 4; color: "#d9a8ff" }
                    Rectangle { width: 54; height: 8; radius: 4; color: "#d9a8ff" }
                }
            }
        }

        Text {
            width: parent.width
            height: 31
            text: root.entry.name
            color: "#fffaff"
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }
    }

    Drag.active: dragHandler.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: root.isLarge ? 69 : 30
    Drag.keys: ["text/plain"]
    Drag.mimeData: ({ "text/plain": root.entry.name })
    Drag.dragType: Drag.Automatic
    DragHandler { id: dragHandler; acceptedButtons: Qt.LeftButton; target: null }
    TapHandler { onTapped: root.addRequested(root.entry.name) }
    ToolTip.visible: dragHandler.active
    ToolTip.text: qsTr("Drag to Control Center or Menu Bar")
    Accessible.name: root.entry.name
    Accessible.role: Accessible.Button
}
