import QtQuick
import QtQuick.Layouts

GlassCard {
    id: root

    property string title: ""
    property real value: 0.5
    property bool sound: false
    property real titleOffsetY: 0
    property real titlePixelSize: 12
    property real titleLetterSpacing: 0
    property color foreground: "#ffffff"
    property color trackColor: Qt.rgba(1, 1, 1, 0.30)
    property color levelColor: "#ffffff"

    cornerRadius: 29
    // Match the screenshot-fitted squircle profile used by LiquidGlass.
    roundness: 3.0
    glassBlurRadius: 8
    fillColor: Qt.rgba(1, 1, 1, 0.06)
    borderColor: Qt.rgba(1, 1, 1, 0.36)

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: root.sound ? 13 : 12
        anchors.topMargin: 8
        anchors.bottomMargin: 7
        spacing: 2

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 2
            text: root.title
            color: root.foreground
            font.family: "SF Pro Text"
            font.pixelSize: root.titlePixelSize
            font.weight: Font.DemiBold
            font.letterSpacing: root.titleLetterSpacing
            verticalAlignment: Text.AlignVCenter
            transform: Translate { y: root.titleOffsetY }
        }

        Item {
            id: sliderRow
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Tahoe centers the thin track independently from the icon row.
            // Keep the end glyphs on the same optical baseline as the track.
            MacIcon {
                id: leadingIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0.5
                width: root.sound ? 20 : 17
                height: root.sound ? 20 : 17
                iconName: root.sound ? "volume-low" : "brightness-low"
                glyphColor: root.sound ? root.foreground : "#a193a0"
                transform: Translate { x: root.sound ? -0.5 : 0 }
            }

            Item {
                id: track
                anchors.left: leadingIcon.right
                anchors.right: root.sound ? volumeIcon.left : trailingIcon.left
                anchors.leftMargin: root.sound ? -1 : 6
                anchors.rightMargin: root.sound ? 10 : 6
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0.5
                height: 4

                Rectangle {
                    anchors.fill: parent
                    radius: 2
                    color: root.trackColor
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(8, parent.width * root.value)
                    height: 4
                    radius: 2
                    color: root.levelColor
                }
            }

            MacIcon {
                id: trailingIcon
                visible: !root.sound
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -1
                width: 19
                height: 19
                iconName: "brightness-high"
                glyphColor: root.foreground
                scale: 0.82
                transform: Translate { x: -2; y: 1 }
            }

            MacIcon {
                id: volumeIcon
                visible: root.sound
                anchors.right: audioOutput.left
                anchors.rightMargin: 8.25
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
                width: 21
                height: 16
                iconName: "cupertino-font-speaker_3_fill"
                stretch: true
                glyphScale: 1.1
                scale: 1.15
                transform: Translate { x: -1.5 }
            }

            Item {
                id: audioOutput
                visible: root.sound
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 2
                width: 27
                height: 27
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.rgba(1, 1, 1, 0.16)
                    border.color: Qt.rgba(1, 1, 1, 0.16)
                    border.width: 1
                }
                MacIcon {
                    anchors.centerIn: parent
                    // Tahoe's AirPlay mark occupies about half the diameter
                    // of its circular sound-output control. The old 13 px
                    // glyph left the three upward arches visibly undersized.
                    width: 15.5
                    height: 15.5
                    iconName: "audio-output"
                    transform: Translate { x: -1 }
                }
            }
        }
    }
}
