import QtQuick
import QtQuick.Window
import "../contents/ui/components"

Window {
    id: preview
    visible: true
    width: 1920
    height: 1080
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    title: "Control Center visual comparison"
    readonly property var materialOverrides: JSON.parse(renderMaterialParametersJson)
    // Screenshot fixture only: these values are read from the supplied
    // macOS reference captures. The installed app always uses live system
    // state from SystemControlController instead.
    readonly property var previewController: ({
        wifiAvailable: true,
        wifiEnabled: true,
        wifiNetworkName: "SannWifi-Freebox",
        wifiNetworkSecured: true,
        wifiOtherNetworks: [],
        refreshWifiNetworks: function() {},
        toggleWifi: function() {},
        openWifiSettings: function() {},
        bluetoothAvailable: true,
        bluetoothEnabled: true,
        bluetoothDevices: [
            {address: "ref-bv5300", name: "BV5300 Pro", connected: true},
            {address: "ref-rebel", name: "Fresh 'n Rebel 3ATW3001R", connected: true},
            {address: "ref-flow", name: "MUSIC SOUND FLOW", connected: true},
            {address: "ref-mx", name: "MX Master", connected: false}
        ],
        refreshBluetoothDevices: function() {},
        toggleBluetooth: function() {},
        toggleBluetoothDevice: function() {},
        openBluetoothSettings: function() {},
        mediaAvailable: false,
        brightnessAvailable: false
    })

    // LiquidGlass uses ShaderEffectSource.hideSource for its backdrop. Keep
    // an identical visible copy underneath and sample a separate sibling so
    // the texture capture cannot hide the desktop preview itself.
    Image {
        id: desktopWallpaper
        width: 1920
        height: 1080
        source: renderWallpaper
        asynchronous: false
        fillMode: Image.Stretch
        smooth: false
    }

    Image {
        id: previewWallpaper
        width: 1920
        height: 1080
        source: renderWallpaper
        asynchronous: false
        fillMode: Image.Stretch
        smooth: false
    }

    ControlCenterPanel {
        id: controlCenter
        x: 1615
        y: 41
        width: 292
        height: 484
        backdropOverride: previewWallpaper
        useLiquidGlass: true
        opacity: 1
        controlController: preview.previewController
    }

    function applyGlassParameters(item) {
        if (!item) return
        // Material overrides target GlassCard surfaces only. Applying
        // fillColor recursively also changes nested decorative shapes
        // (for example the media tile's small placeholder), invalidating
        // visual material sweeps.
        const isGlassCard = item.glassTintStrength !== undefined
                && item.appearanceControl !== true
        const surfaceName = item.objectName || item.title || item.iconName || ""
        const profileScale = renderRefractionProfile[surfaceName]
        const materialKeys = Object.keys(preview.materialOverrides)
        for (let i = 0; i < materialKeys.length; ++i) {
            const propertyName = materialKeys[i]
            if (isGlassCard && item[propertyName] !== undefined)
                item[propertyName] = preview.materialOverrides[propertyName]
        }
        if (item.refractIOR !== undefined)
            item.refractIOR = renderRefractionIOR
        if (item.glassRefractionScale !== undefined
                && (profileScale !== undefined || renderRefractionScale >= 0))
            item.glassRefractionScale = profileScale !== undefined ? profileScale : renderRefractionScale
        if (item.glassRefractionThickness !== undefined && renderRefractionThickness > 0)
            item.glassRefractionThickness = renderRefractionThickness
        if (item.glassBlurRadius !== undefined && renderBlurRadius >= 0
                && preview.materialOverrides.glassBlurRadius === undefined)
            item.glassBlurRadius = renderBlurRadius
        if (item.glassChromaStrength !== undefined && preview.materialOverrides.glassChromaStrength === undefined)
            item.glassChromaStrength = renderChromaStrength
        // Material-sweep values win over global CLI defaults. Apply these
        // last so per-candidate blur and tint settings survive.
        for (let i = 0; i < materialKeys.length; ++i) {
            const propertyName = materialKeys[i]
            if (isGlassCard && item[propertyName] !== undefined)
                item[propertyName] = preview.materialOverrides[propertyName]
        }
        if (item.children) {
            for (let i = 0; i < item.children.length; ++i)
                applyGlassParameters(item.children[i])
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            preview.applyGlassParameters(controlCenter)
            if (renderState === "wifi-menu")
                controlCenter.openWifiDetails()
            else if (renderState === "bluetooth-menu")
                controlCenter.openBluetoothDetails()
        }
    }
}
