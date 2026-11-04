import QtQuick

Item {
    id: root

    property real cornerRadius: 18
    property real roundness: 2.5
    property color fillColor: Qt.rgba(0.38, 0.25, 0.56, 0.34)
    property color borderColor: Qt.rgba(1, 1, 1, 0.34)
    property real borderWidth: 1
    property bool disabled: false
    property bool useLiquidGlass: true
    property Item backdropOverride: null
    property bool solidMode: false
    property color solidColor: "#ffffff"
    // Keep a restrained live backdrop blur inside each capsule; the masked
    // outer halo adds a separate progressive accessibility-softening band.
    property real glassBlurRadius: 6
    property int glassBlurAlgorithm: 1
    property real glassTintStrength: 0.0
    property real glassRefractionThickness: 35
    property real glassRefractionScale: 75
    property real glassChromaStrength: 0.0
    property real glassOuterBlurRadius: 6
    property real glassOuterBlurStrength: 0.80
    property real glassInnerBlurMix: 1.0
    default property alias contentData: content.data

    SquircleSurface {
        anchors.fill: parent
        visible: !root.useLiquidGlass
        radius: root.cornerRadius
        fillColor: root.solidMode ? root.solidColor : root.fillColor
        strokeColor: root.borderColor
        strokeWidth: root.borderWidth
        cornerExponent: root.roundness
    }

    Loader {
        anchors.fill: parent
        active: root.useLiquidGlass
        source: active ? Qt.resolvedUrl("LiquidGlass.qml") : ""
        onLoaded: {
            // Keep the glass item bound to its card. One-time assignments
            // capture QML defaults if the Loader completes before the
            // parent's geometry settles (notably cornerRadius=18), making
            // capsules render as small rounded rectangles.
            item.radius = Qt.binding(function() { return root.cornerRadius; });
            item.roundness = Qt.binding(function() { return root.roundness; });
            item.solidMode = Qt.binding(function() { return root.solidMode; });
            item.solidColor = Qt.binding(function() { return root.solidColor; });
            item.backdropOverride = Qt.binding(function() { return root.backdropOverride; });
            item.blurRadius = Qt.binding(function() { return root.glassBlurRadius; });
            item.blurAlgorithm = Qt.binding(function() { return root.glassBlurAlgorithm; });
            item.refractThickness = Qt.binding(function() { return root.glassRefractionThickness; });
            item.refractScale = Qt.binding(function() { return root.glassRefractionScale; });
            item.outerBlurRadius = Qt.binding(function() { return root.glassOuterBlurRadius; });
            item.outerBlurStrength = Qt.binding(function() { return root.glassOuterBlurStrength; });
            item.innerBlurMix = Qt.binding(function() { return root.glassInnerBlurMix; });
            item.tint = Qt.binding(function() {
                return Qt.rgba(root.fillColor.r, root.fillColor.g,
                               root.fillColor.b, 1);
            });
            item.tintAlpha = Qt.binding(function() { return root.fillColor.a * root.glassTintStrength; });
            item.chromaStrength = Qt.binding(function() { return root.glassChromaStrength; });
        }
    }

    SquircleSurface {
        anchors.fill: parent
        visible: root.useLiquidGlass && !root.solidMode
        radius: root.cornerRadius
        fillColor: Qt.rgba(0, 0, 0, 0)
        strokeColor: Qt.rgba(root.borderColor.r, root.borderColor.g,
                              root.borderColor.b, root.borderColor.a * 0.66)
        strokeWidth: root.borderWidth
        cornerExponent: root.roundness
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: root.disabled ? 0.82 : 1
    }

}
