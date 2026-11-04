import QtQuick
import QtCore

Item {
    id: root
    width: 292
    height: 489
    implicitWidth: width
    implicitHeight: height
    property color foreground: "#f8f5ff"
    property Item backdropOverride: null
    property bool useLiquidGlass: true
    property var controlController: typeof systemControls !== "undefined" ? systemControls : null
    readonly property bool detailsOpen: wifiDetails.visible || bluetoothDetails.visible
    readonly property var defaultControlCenterItems: ["AirDrop", "Bluetooth", "Wi-Fi", "Stage Manager", "Screen Mirroring", "Appearance", "Screenshot", "Focus", "Display", "Sound", "Now Playing"]
    readonly property bool customLayout: !sameList(savedControlLayout.controlCenterItems, defaultControlCenterItems)
    signal editControlsRequested()
    Settings {
        id: savedControlLayout
        category: "ControlCenter"
        property var controlCenterItems: ["AirDrop", "Bluetooth", "Wi-Fi", "Stage Manager", "Screen Mirroring", "Appearance", "Screenshot", "Focus", "Display", "Sound", "Now Playing"]
    }
    function sameList(a, b) {
        if (!a || a.length !== b.length) return false
        for (let i = 0; i < a.length; ++i) if (a[i] !== b[i]) return false
        return true
    }
    function controlIsSelected(name) {
        return savedControlLayout.controlCenterItems.indexOf(name) >= 0
    }
    function customIcon(name) {
        switch (name) {
        case "Wi-Fi": return "cupertino-font-wifi"
        case "Bluetooth": return "cupertino-font-bluetooth"
        case "AirDrop": return "airdrop-muted"
        case "Stage Manager": return "stage-manager"
        case "Screen Mirroring": return "screen-mirroring"
        case "Appearance": case "Dark Mode": return "appearance"
        case "Screenshot": return "screenshot"
        case "Focus": return "cupertino-font-moon_fill"
        case "Display": return "brightness-high"
        case "Sound": return "cupertino-font-speaker_3_fill"
        case "Now Playing": case "Recognize Music": return "cupertino-font-music_note"
        case "Battery": return "cupertino-font-battery_100"
        case "Clock": case "Alarm": case "Stopwatch": case "Timer": return "cupertino-font-clock"
        case "Notes": case "Quick Note": return "cupertino-font-note_text"
        case "Voice Memo": return "cupertino-font-waveform"
        case "Keyboard Brightness": return "cupertino-font-keyboard"
        case "Lock Screen": return "cupertino-font-lock_fill"
        case "Home": return "cupertino-font-house_fill"
        case "Utilities": return "cupertino-font-wrench_fill"
        default: return "cupertino-font-square_grid_2x2_fill"
        }
    }
    function customIsDisabled(name) {
        return ["AirDrop", "Focus", "Battery", "Alarm", "Stopwatch", "Timer", "Application Windows", "Dock Auto-hide", "Mission Control", "Show Desktop", "Tile Windows Left & Corners", "Tile Windows Left & Right", "Tile Windows to Corners", "Fast User Switching", "Home", "Keyboard Brightness", "Lock Screen", "Microsoft Teams", "Notes", "Shortcuts", "Utilities", "Scene or Accessory", "Run Shortcut", "Voice Memo", "Quick Note", "Recognize Music", "Start Screen Saver"].indexOf(name) >= 0
    }

    function openWifiDetails() { wifiDetails.open() }
    function openBluetoothDetails() { bluetoothDetails.open() }

    Connections {
        target: typeof trayController !== "undefined" ? trayController : null
        function onMenuBarControlActivated(name) {
            if (name === "Wi-Fi") root.openWifiDetails()
            else if (name === "Bluetooth") root.openBluetoothDetails()
        }
    }

    QuickTile {
        id: wifiTile
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Wi-Fi")
        x: 0; y: 0; width: 140; height: 62
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassTintStrength: 1.0
        glassRefractionScale: 85
        glassRefractionThickness: 25
        iconName: "cupertino-font-wifi"
        hasSubmenu: true
        iconColor: "#007aff"
        iconBadge: true
        badgeSize: 36
        badgeIconSize: 22
        badgeBackgroundOffsetX: -2
        badgeBackgroundOffsetY: 1
        badgeIconOffsetX: -2.1
        badgeIconOffsetY: 2.4
        labelOffsetX: -2
        labelOffsetY: 2
        active: true
        title: "Wi-Fi"
        subtitle: root.controlController
            ? (root.controlController.wifiEnabled
               ? (root.controlController.wifiNetworkName.length
                  ? root.controlController.wifiNetworkName : qsTr("On"))
               : qsTr("Off"))
            : "SannWifi-\nFreebox"
        interactive: root.controlController !== null
        onActivated: wifiDetails.open()
        foreground: root.foreground
        badgeColor: "#ffffff"
    }

    ControlDetailsPopup {
        id: wifiDetails
        ownerItem: root
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        controlController: root.controlController
    }

    QuickTile {
        id: bluetoothTile
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Bluetooth")
        x: 0; y: 77; width: 140; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassTintStrength: 1.0
        glassRefractionThickness: 25
        iconName: "cupertino-font-bluetooth"
        hasSubmenu: true
        iconColor: "#007aff"
        iconBadge: true
        badgeSize: 36
        badgeIconSize: 22
        badgeBackgroundOffsetX: -2
        badgeIconOffsetX: -2.65
        badgeIconOffsetY: 0.6
        labelOffsetX: -2
        labelOffsetY: 2
        active: true
        title: "Bluetooth"
        subtitle: root.controlController
            ? (root.controlController.bluetoothEnabled ? "On" : "Off")
            : "On"
        interactive: root.controlController !== null
        onActivated: bluetoothDetails.open()
        foreground: root.foreground
        badgeColor: "#ffffff"
        tileFill: Qt.rgba(1, 1, 1, 0.07)
    }
    BluetoothDetailsPopup {
        id: bluetoothDetails
        ownerItem: root
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        controlController: root.controlController
    }
    QuickTile {
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("AirDrop")
        x: 0; y: 153; width: 140; height: 62
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        roundness: 2.0
        glassRefractionThickness: 36
        glassRefractionScale: 62
        glassBlurRadius: 10
        glassBlurAlgorithm: 1
        glassTintStrength: 1.0
        iconName: "airdrop-muted"
        iconBadge: true
        badgeSize: 36
        badgeIconSize: 22
        badgeLeftMargin: 15
        badgeIconOffsetX: -1
        badgeIconOffsetY: -0.5
        labelOffsetX: -2
        labelOffsetY: 2
        title: "AirDrop"
        subtitle: "Off"
        disabled: true
        foreground: root.foreground
        secondaryForeground: Qt.rgba(1, 1, 1, 0.68)
        badgeColor: Qt.rgba(0.76, 0.78, 0.82, 0.14)
        tileFill: Qt.rgba(1, 1, 1, 0.07)
    }

    GlassCard {
        objectName: "Media"
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Now Playing")
        x: 152; y: 0; width: 140; height: 139
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassBlurRadius: 10
        glassRefractionThickness: 36
        glassTintStrength: 1.0
        glassChromaStrength: 0.0
        cornerRadius: 33
        roundness: 3.0
        fillColor: Qt.rgba(1, 1, 1, 0.07)
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
                    required property int index
                    width: 40
                    height: 26
                    MacIcon {
                        anchors.centerIn: parent
                        width: mediaControl.modelData === "cupertino-font-play_fill" ? 21 : 21
                        height: mediaControl.modelData === "cupertino-font-play_fill" ? 21 : 11
                        stretch: mediaControl.modelData !== "cupertino-font-play_fill"
                        glyphScale: mediaControl.modelData === "cupertino-font-play_fill" ? 1.35 : 2.0
                        iconName: mediaControl.modelData
                        opacity: {
                            const referenceOpacity = mediaControl.modelData === "cupertino-font-play_fill" ? 0.61 : 0.40
                            return !root.controlController || root.controlController.mediaAvailable
                                ? referenceOpacity : 0.22
                        }
                        transform: Translate {
                            x: mediaControl.modelData === "cupertino-font-play_fill" ? 2 : (mediaControl.modelData === "cupertino-font-forward_fill" ? 1 : 0)
                            y: mediaControl.modelData === "cupertino-font-play_fill" ? 1 : 2
                        }
                    }
                    TapHandler {
                        enabled: root.controlController && root.controlController.mediaAvailable
                        onTapped: {
                            if (mediaControl.index === 0) root.controlController.mediaPrevious()
                            else if (mediaControl.index === 1) root.controlController.mediaTogglePlayback()
                            else root.controlController.mediaNext()
                        }
                    }
                }
            }
        }
    }

    QuickTile {
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Stage Manager")
        x: 152; y: 153; width: 64; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        iconName: "stage-manager"
        glassTintStrength: 1.0
        glassRefractionThickness: 28
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
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Screen Mirroring")
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
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Appearance")
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
        interactive: root.controlController !== null
        onActivated: if (root.controlController) root.controlController.toggleAppearance()
        solidMode: true
        title: ""
        foreground: "#000000"
        Accessible.name: "Appearance"
    }
    QuickTile {
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Screenshot")
        x: 76; y: 229; width: 64; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassTintStrength: 1.0
        glassRefractionThickness: 25
        iconName: "screenshot"
        interactive: root.controlController !== null
        onActivated: if (root.controlController) root.controlController.launchScreenshot()
        iconSize: 28.5
        iconHeight: 28.5
        iconOffsetX: -1.5
        iconOffsetY: 1.0
        circular: true
        compact: true
        title: ""
        foreground: root.foreground
        Accessible.name: "Screenshot"
    }
    QuickTile {
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Focus")
        x: 152; y: 229; width: 140; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassTintStrength: 1.0
        glassRefractionThickness: 22
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
        tileFill: Qt.rgba(1, 1, 1, 0.07)
        Accessible.name: "Focus"
    }

    SliderCard {
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Display")
        x: 0; y: 306; width: 292; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassRefractionThickness: 25
        glassTintStrength: 1.0
        title: "Display"
        titleOffsetY: 3
        titlePixelSize: 12.25
        titleLetterSpacing: 0.15
        value: 1
        interactive: false
        trackColor: Qt.rgba(1, 1, 1, 0.14)
        levelColor: Qt.rgba(1, 1, 1, 0.14)
        foreground: root.foreground
    }
    SliderCard {
        visible: !root.customLayout && !root.detailsOpen && root.controlIsSelected("Sound")
        x: 0; y: 383; width: 292; height: 64
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassRefractionThickness: 25
        glassTintStrength: 1.0
        title: "Sound"
        titleOffsetY: 3
        sound: true
        value: root.controlController ? root.controlController.volume / 100 : 0.675
        interactive: root.controlController !== null
        onValueEdited: if (root.controlController) root.controlController.setVolume(Math.round(value * 100))
        trackColor: Qt.rgba(1, 1, 1, 0.24)
        levelColor: "#ffffff"
        foreground: root.foreground
    }

    GlassCard {
        objectName: "Edit Controls"
        visible: !root.detailsOpen
        x: 99; y: 464; width: 94; height: 25
        backdropOverride: root.backdropOverride
        useLiquidGlass: root.useLiquidGlass
        glassRefractionThickness: 25
        glassTintStrength: 1.0
        cornerRadius: 12.5
        roundness: 2.0
        fillColor: Qt.rgba(1, 1, 1, 0.07)
        borderColor: Qt.rgba(1, 1, 1, 0.32)
        TapHandler { onTapped: root.editControlsRequested() }
        Accessible.role: Accessible.Button
        Accessible.name: qsTr("Edit Controls")
        Text {
            anchors.centerIn: parent
            text: "Edit Controls"
            color: root.foreground
            font.family: "SF Pro Text"
            font.pixelSize: 11
            Accessible.name: text
        }
    }

    // A changed selection/order is rendered from the saved list itself. This
    // keeps the carefully fitted reference layout untouched until the user
    // edits it, while making added controls and their order visible at once.
    Flickable {
        id: customControlsViewport
        visible: root.customLayout && !root.detailsOpen
        x: 0; y: 0; width: root.width; height: 451
        clip: true
        contentWidth: width
        contentHeight: customControlsFlow.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        Flow {
            id: customControlsFlow
            width: customControlsViewport.width
            spacing: 12
            Repeater {
                model: savedControlLayout.controlCenterItems
                delegate: Item {
                    id: customControl
                    required property string modelData
                    width: (modelData === "Display" || modelData === "Sound") ? 292
                         : (modelData === "Now Playing" ? 140 : 140)
                    height: modelData === "Now Playing" ? 139 : 64

                    QuickTile {
                        anchors.fill: parent
                        visible: customControl.modelData !== "Display" && customControl.modelData !== "Sound" && customControl.modelData !== "Now Playing"
                        backdropOverride: root.backdropOverride
                        useLiquidGlass: root.useLiquidGlass
                        iconName: root.customIcon(customControl.modelData)
                        iconBadge: true
                        badgeSize: 36
                        badgeIconSize: 22
                        iconColor: customControl.modelData === "Wi-Fi" || customControl.modelData === "Bluetooth" ? "#007aff" : root.foreground
                        badgeColor: "#ffffff"
                        title: customControl.modelData
                        subtitle: customControl.modelData === "Wi-Fi"
                            ? (root.controlController && root.controlController.wifiEnabled
                               ? (root.controlController.wifiNetworkName.length ? root.controlController.wifiNetworkName : qsTr("On")) : qsTr("Off"))
                            : customControl.modelData === "Bluetooth"
                              ? (root.controlController && root.controlController.bluetoothEnabled ? qsTr("On") : qsTr("Off"))
                              : root.customIsDisabled(customControl.modelData) ? qsTr("Unavailable") : ""
                        hasSubmenu: customControl.modelData === "Wi-Fi" || customControl.modelData === "Bluetooth"
                        disabled: root.customIsDisabled(customControl.modelData)
                        interactive: customControl.modelData === "Wi-Fi" || customControl.modelData === "Bluetooth"
                            || customControl.modelData === "Appearance" || customControl.modelData === "Screenshot"
                        onActivated: {
                            if (customControl.modelData === "Wi-Fi") wifiDetails.open()
                            else if (customControl.modelData === "Bluetooth") bluetoothDetails.open()
                            else if (customControl.modelData === "Appearance" && root.controlController) root.controlController.toggleAppearance()
                            else if (customControl.modelData === "Screenshot" && root.controlController) root.controlController.launchScreenshot()
                        }
                        foreground: root.foreground
                        tileFill: Qt.rgba(1, 1, 1, 0.07)
                    }
                    GlassCard {
                        anchors.fill: parent
                        visible: customControl.modelData === "Now Playing"
                        backdropOverride: root.backdropOverride
                        useLiquidGlass: root.useLiquidGlass
                        glassBlurRadius: 10
                        glassRefractionThickness: 36
                        glassTintStrength: 1.0
                        glassChromaStrength: 0.0
                        cornerRadius: 33
                        roundness: 3.0
                        fillColor: Qt.rgba(1, 1, 1, 0.07)
                        borderColor: Qt.rgba(1, 1, 1, 0.35)
                        SquircleSurface {
                            x: 14; y: 12; width: 42; height: 42
                            radius: 14; cornerExponent: 3.0
                            fillColor: Qt.rgba(1, 1, 1, 0.06)
                            strokeColor: Qt.rgba(1, 1, 1, 0.04)
                            strokeWidth: 0.5
                        }
                        Text {
                            x: 14; y: 73; width: parent.width - 26
                            text: root.controlController && root.controlController.mediaAvailable
                                ? qsTr("Now Playing") : qsTr("Not Playing")
                            color: root.foreground
                            font.family: "SF Pro Text"; font.pixelSize: 12; font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Row {
                            x: 10; y: 98; width: parent.width - 20; height: 26
                            Repeater {
                                model: ["cupertino-font-backward_fill", "cupertino-font-play_fill", "cupertino-font-forward_fill"]
                                delegate: Item {
                                    required property string modelData
                                    required property int index
                                    width: 40; height: 26
                                    MacIcon {
                                        anchors.centerIn: parent
                                        width: 21; height: modelData === "cupertino-font-play_fill" ? 21 : 11
                                        stretch: modelData !== "cupertino-font-play_fill"
                                        glyphScale: modelData === "cupertino-font-play_fill" ? 1.35 : 2.0
                                        iconName: modelData
                                        opacity: root.controlController && root.controlController.mediaAvailable ? 0.55 : 0.28
                                    }
                                    TapHandler {
                                        enabled: root.controlController && root.controlController.mediaAvailable
                                        onTapped: {
                                            if (index === 0) root.controlController.mediaPrevious()
                                            else if (index === 1) root.controlController.mediaTogglePlayback()
                                            else root.controlController.mediaNext()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    SliderCard {
                        anchors.fill: parent
                        visible: customControl.modelData === "Display" || customControl.modelData === "Sound"
                        backdropOverride: root.backdropOverride
                        useLiquidGlass: root.useLiquidGlass
                        title: customControl.modelData
                        sound: customControl.modelData === "Sound"
                        value: sound && root.controlController ? root.controlController.volume / 100 : 1
                        interactive: sound && root.controlController !== null
                        onValueEdited: if (root.controlController) root.controlController.setVolume(Math.round(value * 100))
                        foreground: root.foreground
                    }
                }
            }
        }
    }
}
