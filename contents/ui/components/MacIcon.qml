import QtQuick

Image {
    id: root

    property string iconName: ""
    // Some Control Center glyphs are optically non-square in the reference.
    property bool stretch: false
    property color glyphColor: "#ffffff"
    property real glyphScale: 1.0
    readonly property bool isCupertinoFontGlyph: iconName.startsWith("cupertino-font-")
    readonly property string cupertinoLigature: isCupertinoFontGlyph
                                               ? iconName.substring("cupertino-font-".length)
                                               : ""
    source: isCupertinoFontGlyph ? "" : Qt.resolvedUrl("icons/" + iconName + ".svg")
    sourceSize.width: Math.max(32, Math.round(width * 2))
    sourceSize.height: Math.max(32, Math.round(height * 2))
    fillMode: root.stretch ? Image.Stretch : Image.PreserveAspectFit
    smooth: true
    mipmap: false

    FontLoader {
        id: cupertinoFont
        source: root.isCupertinoFontGlyph ? Qt.resolvedUrl("icons/CupertinoIcons.ttf") : ""
    }

    Text {
        anchors.fill: parent
        visible: root.isCupertinoFontGlyph
        text: root.cupertinoLigature
        color: root.glyphColor
        font.family: cupertinoFont.name
        font.pixelSize: Math.min(root.width, root.height) * root.glyphScale
        font.weight: Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.QtRendering
        antialiasing: true
    }

}
