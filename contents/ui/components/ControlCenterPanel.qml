import QtQuick

Item {
    id: root
    width: 292
    height: 489
    implicitWidth: width
    implicitHeight: height
    property color foreground: "#f8f5ff"
    property Item backdropOverride: null
    property bool useLiquidGlass: true

    QuickTile {
        x: 0; y: 0; width: 140; height: 62
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassTintStrength: 1.0
        glassRefractionScale: 85
        glassRefractionThickness: 25
        iconName: "cupertino-font-wifi"
        iconColor: "#007aff"
        iconBadge: true
        badgeSize: 36
        badgeIconSize: 22
        badgeBackgroundOffsetX: -2
        badgeBackgroundOffsetY: 1
        badgeIconOffsetX: -2.1
        badgeIconOffsetY: 2.4
        labelOffsetX: -1
        labelOffsetY: 1
        active: true
        title: "Wi-Fi"
        subtitle: "SannWifi-\nFreebox"
        foreground: root.foreground
        badgeColor: "#ffffff"
    }
    QuickTile {
        x: 0; y: 77; width: 140; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassTintStrength: 1.0
        glassRefractionThickness: 25
        iconName: "cupertino-font-bluetooth"
        iconColor: "#007aff"
        iconBadge: true
        badgeSize: 36
        badgeIconSize: 22
        badgeBackgroundOffsetX: -2
        badgeIconOffsetX: -2.65
        badgeIconOffsetY: 0.6
        labelOffsetX: -1
        labelOffsetY: 1
        active: true
        title: "Bluetooth"
        subtitle: "On"
        foreground: root.foreground
        badgeColor: "#ffffff"
        tileFill: Qt.rgba(1, 1, 1, 0.06)
    }
    QuickTile {
        x: 0; y: 153; width: 140; height: 62
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        roundness: 2.0
        glassRefractionThickness: 30
        glassRefractionScale: 75
        glassBlurRadius: 6
        glassBlurAlgorithm: 1
        glassTintStrength: 1.0
        iconName: "airdrop-muted"
        iconBadge: true
        badgeSize: 36
        badgeIconSize: 22
        badgeLeftMargin: 15
        badgeIconOffsetX: -1
        badgeIconOffsetY: -0.5
        labelOffsetX: -1
        labelOffsetY: 1
        title: "AirDrop"
        subtitle: "Off"
        disabled: true
        foreground: root.foreground
        secondaryForeground: Qt.rgba(1, 1, 1, 0.68)
        badgeColor: Qt.rgba(0.76, 0.78, 0.82, 0.14)
        tileFill: Qt.rgba(1, 1, 1, 0.06)
    }

    GlassCard {
        objectName: "Media"
        x: 152; y: 0; width: 140; height: 139
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassBlurRadius: 6
        glassRefractionThickness: 25
        glassTintStrength: 1.0
        glassChromaStrength: 0.0
        cornerRadius: 33
        roundness: 3.0
        fillColor: Qt.rgba(1, 1, 1, 0.06)
        borderColor: Qt.rgba(1, 1, 1, 0.35)

        SquircleSurface {
            x: 14; y: 12; width: 42; height: 42
            radius: 14
            cornerExponent: 3.0
            fillColor: Qt.rgba(1, 1, 1, 0.06)
            strokeColor: Qt.rgba(1, 1, 1, 0.04)
            strokeWidth: 0.5
        }
        Text {
            x: 14; y: 73; width: parent.width - 26
            text: "Not Playing"
            color: root.foreground
            font.family: "SF Pro Text"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            renderType: Text.QtRendering
        }
        Row {
            x: 10; y: 98; width: parent.width - 20; height: 26
            Repeater {
                model: ["cupertino-font-backward_fill", "cupertino-font-play_fill", "cupertino-font-forward_fill"]
                delegate: Item {
                    id: mediaControl
                    required property string modelData
                    width: 40
                    height: 26
                    MacIcon {
                        anchors.centerIn: parent
                        width: mediaControl.modelData === "cupertino-font-play_fill" ? 21 : 21
                        height: mediaControl.modelData === "cupertino-font-play_fill" ? 21 : 11
                        stretch: mediaControl.modelData !== "cupertino-font-play_fill"
                        glyphScale: mediaControl.modelData === "cupertino-font-play_fill" ? 1.35 : 2.0
                        iconName: mediaControl.modelData
                        opacity: mediaControl.modelData === "cupertino-font-play_fill" ? 0.61 : 0.40
                        transform: Translate {
                            x: mediaControl.modelData === "cupertino-font-play_fill" ? 2 : (mediaControl.modelData === "cupertino-font-forward_fill" ? 1 : 0)
                            y: mediaControl.modelData === "cupertino-font-play_fill" ? 1 : 2
                        }
                    }
                }
            }
        }
    }

    QuickTile {
        x: 152; y: 153; width: 64; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        iconName: "stage-manager"
        glassTintStrength: 1.0
        iconSize: 33.5
        iconHeight: 35.2
        iconOffsetX: -1
        iconOffsetY: 1.5
        circular: true
        compact: true
        active: true
        title: ""
        foreground: root.foreground
        Accessible.name: "Stage Manager"
    }
    QuickTile {
        x: 228; y: 153; width: 64; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        iconName: "screen-mirroring"
        glassTintStrength: 1.0
        iconSize: 27.3
        iconOffsetX: 0
        iconOffsetY: 2
        circular: true
        compact: true
        title: ""
        foreground: root.foreground
        Accessible.name: "Screen Mirroring"
    }

    QuickTile {
        x: -1; y: 230; width: 64; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        iconName: "appearance"
        iconSize: 27.25
        iconOffsetX: 1.8
        iconOffsetY: 0.6
        circular: true
        compact: true
        appearanceControl: true
        solidMode: true
        title: ""
        foreground: "#000000"
        Accessible.name: "Appearance"
    }
    QuickTile {
        x: 76; y: 229; width: 64; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassTintStrength: 1.0
        glassRefractionThickness: 25
        iconName: "screenshot"
        iconSize: 27.5
        iconHeight: 27.5
        iconOffsetX: -1.5
        iconOffsetY: 1.0
        circular: true
        compact: true
        title: ""
        foreground: root.foreground
        Accessible.name: "Screenshot"
    }
    QuickTile {
        x: 152; y: 229; width: 140; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassTintStrength: 1.0
        iconName: "cupertino-font-moon_fill"
        iconBadge: true
        badgeSize: 40
        badgeIconSize: 21
        badgeLeftMargin: 8
        badgeIconOffsetX: 4.5
        badgeIconOffsetY: -0.5
        badgeBackgroundOffsetX: 5
        labelOffsetX: 2
        badgeColor: Qt.rgba(1, 1, 1, 0.16)
        title: "Focus"
        subtitle: ""
        disabled: true
        foreground: root.foreground
        tileFill: Qt.rgba(1, 1, 1, 0.06)
        Accessible.name: "Focus"
    }

    SliderCard {
        x: 0; y: 306; width: 292; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassRefractionThickness: 25
        glassTintStrength: 1.0
        title: "Display"
        titleOffsetY: 4
        titlePixelSize: 12.25
        titleLetterSpacing: 0.15
        value: 1
        trackColor: Qt.rgba(1, 1, 1, 0.14)
        levelColor: Qt.rgba(1, 1, 1, 0.14)
        foreground: root.foreground
    }
    SliderCard {
        x: 0; y: 383; width: 292; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassRefractionThickness: 25
        glassTintStrength: 1.0
        title: "Sound"
        titleOffsetY: 3
        sound: true
        value: 0.675
        trackColor: Qt.rgba(1, 1, 1, 0.24)
        levelColor: "#ffffff"
        foreground: root.foreground
    }

    GlassCard {
        objectName: "Edit Controls"
        x: 99; y: 464; width: 94; height: 25
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassRefractionThickness: 25
        glassTintStrength: 1.0
        cornerRadius: 12.5
        roundness: 2.0
        fillColor: Qt.rgba(1, 1, 1, 0.06)
        borderColor: Qt.rgba(1, 1, 1, 0.32)
        Text {
            anchors.centerIn: parent
            text: "Edit Controls"
            color: root.foreground
            font.family: "SF Pro Text"
            font.pixelSize: 11
            Accessible.name: text
        }
    }
}
