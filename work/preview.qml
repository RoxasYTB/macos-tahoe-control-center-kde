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
    }

    function applyGlassParameters(item) {
        if (!item) return
        const surfaceName = item.objectName || item.title || item.iconName || ""
        const profileScale = renderRefractionProfile[surfaceName]
        for (const propertyName in renderMaterialParameters) {
            if (item[propertyName] !== undefined)
                item[propertyName] = renderMaterialParameters[propertyName]
        }
        if (item.refractIOR !== undefined)
            item.refractIOR = renderRefractionIOR
        if (item.glassRefractionScale !== undefined)
            item.glassRefractionScale = profileScale !== undefined ? profileScale : renderRefractionScale
        if (item.glassRefractionThickness !== undefined && renderRefractionThickness > 0)
            item.glassRefractionThickness = renderRefractionThickness
        if (item.glassBlurRadius !== undefined && renderMaterialParameters.glassBlurRadius === undefined)
            item.glassBlurRadius = renderBlurRadius
        if (item.glassChromaStrength !== undefined && renderMaterialParameters.glassChromaStrength === undefined)
            item.glassChromaStrength = renderChromaStrength
        // Material-sweep values win over global CLI defaults. Apply these
        // last so per-candidate blur, tint and reflection settings survive.
        for (const propertyName in renderMaterialParameters) {
            if (item[propertyName] !== undefined)
                item[propertyName] = renderMaterialParameters[propertyName]
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
        onTriggered: preview.applyGlassParameters(controlCenter)
    }
}
