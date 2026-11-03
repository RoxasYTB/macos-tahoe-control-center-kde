import QtQuick
import QtQuick.Layouts

GlassCard {
    id: root

    property string iconName: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool circular: false
    property bool compact: false
    property bool iconBadge: false
    property real badgeSize: 36
    property real badgeIconSize: 24
    property real badgeIconOffsetX: 0
    property real badgeIconOffsetY: 0
    property real badgeLeftMargin: 15
    property real badgeBackgroundOffsetX: 0
    property real iconOffsetX: 0
    property real iconOffsetY: 0
    property real labelOffsetX: 0
    property real labelOffsetY: 0
    property bool appearanceControl: false
    property real iconSize: 24
    // Optional optical height for the screenshot-matched utility glyphs.
    property real iconHeight: 0
    property color iconColor: root.foreground
    property color foreground: "#ffffff"
    property color secondaryForeground: Qt.rgba(1, 1, 1, 0.76)
    property color badgeColor: Qt.rgba(1, 1, 1, 0)
    // A restrained neutral veil keeps the glass legible over dark live
    // content without imposing a pink/purple tint on the sampled backdrop.
    property color tileFill: Qt.rgba(1, 1, 1, 0.06)
    property color tileBorder: Qt.rgba(1, 1, 1, 0.38)

    cornerRadius: circular ? width / 2 : (height / 2)
    // Tahoe capsules have semicircular ends; circular controls remain exact
    // circles through the same exponent.
    roundness: 2.0
    fillColor: appearanceControl ? "transparent" : tileFill
    borderColor: appearanceControl ? "transparent" : tileBorder
    borderWidth: appearanceControl ? 0 : 1
    solidMode: appearanceControl
    solidColor: "#ffffff"
    Accessible.role: Accessible.Button
    Accessible.name: subtitle.length ? title + ", " + subtitle : title

    Item {
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: root.iconBadge ? root.badgeLeftMargin : (root.compact ? 7 : 4)
            anchors.rightMargin: root.compact ? 7 : 8
            spacing: root.compact ? 6 : (root.iconBadge ? 6 : 12)
            visible: !root.circular || root.title.length > 0 || root.iconBadge

            Item {
                visible: root.iconBadge
                Layout.preferredWidth: root.badgeSize
                Layout.preferredHeight: root.badgeSize
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: root.badgeColor
                    visible: root.badgeColor.a > 0
                    transform: Translate { x: root.badgeBackgroundOffsetX }
                }
                MacIcon {
                    x: (parent.width - width) / 2 + root.badgeIconOffsetX
                    y: (parent.height - height) / 2 + root.badgeIconOffsetY
                    width: root.badgeIconSize
                    height: root.badgeIconSize
                    iconName: root.iconName
                    glyphColor: root.iconColor
                    opacity: root.disabled ? 0.68 : 1
                }
            }

            ColumnLayout {
                Layout.leftMargin: root.labelOffsetX
                Layout.topMargin: root.labelOffsetY
                visible: root.title.length > 0
                Layout.fillWidth: true
                spacing: -1
                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: root.foreground
                    font.family: "SF Pro Text"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    Layout.fillWidth: true
                    text: root.subtitle
                    color: root.secondaryForeground
                    font.family: "SF Pro Text"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    visible: text.length > 0
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                }
            }
        }

        MacIcon {
            visible: root.circular && root.title.length === 0 && !root.iconBadge
            x: (parent.width - width) / 2 + root.iconOffsetX
            y: (parent.height - height) / 2 + root.iconOffsetY
            width: root.iconSize
            height: root.iconHeight > 0 ? root.iconHeight : root.iconSize
            stretch: root.iconHeight > 0
            iconName: root.iconName
            glyphColor: root.iconColor
        }

    }
}
