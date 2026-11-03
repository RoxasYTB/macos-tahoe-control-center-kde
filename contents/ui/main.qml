pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "components"
import "native" as ControlCenterNative

PlasmoidItem {
    id: root

    property bool panelVisible: false
    preferredRepresentation: compactRepresentation
    activationTogglesExpanded: false
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.status: panelVisible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus
    toolTipMainText: i18n("Control Center")
    toolTipSubText: i18n("Quick settings")

    compactRepresentation: PlasmaComponents.ToolButton {
        id: controlButton
        text: ""
        display: PlasmaComponents.AbstractButton.IconOnly
        Accessible.name: i18n("Control Center")
        onClicked: popup.visible = !popup.visible
        contentItem: MacIcon {
            iconName: "control-center-white"
            width: 19
            height: 19
        }
    }

    fullRepresentation: Item {
        visible: false
        implicitWidth: 1
        implicitHeight: 1
    }

    PlasmaCore.AppletPopup {
        id: popup
        visualParent: root
        popupDirection: Qt.BottomEdge
        margin: 0
        appletInterface: root
        backgroundHints: PlasmaCore.Dialog.NoBackground
        hideOnWindowDeactivate: true
        visible: root.panelVisible
        onVisibleChanged: root.panelVisible = visible

        mainItem: Item {
            width: 365
            height: 544

            ControlCenterPanel {
                x: 60
                y: 0
                useLiquidGlass: false
            }
        }
    }

    ControlCenterNative.BlurBehindRegion {
        window: popup
        maskSource: Qt.resolvedUrl("components/icons/control-center-blur-window-region.png")
        // KWin exposes a binary blur region (not per-window blur strength).
        // Keep only the strongest, narrow halo pixels to avoid a heavy wash.
        alphaThreshold: 35
        enabled: popup.visible
    }
}
