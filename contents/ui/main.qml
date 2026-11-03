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
    Plasmoid.icon: "control-centre-iconscout-white"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.status: panelVisible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.ActiveStatus
    toolTipMainText: i18n("Control Center")
    toolTipSubText: i18n("Quick settings")

    compactRepresentation: PlasmaComponents.ToolButton {
        id: controlButton
        text: ""
        display: PlasmaComponents.AbstractButton.IconOnly
        Accessible.name: i18n("Control Center")
        onClicked: popup.visible = !popup.visible
        contentItem: Item {
            width: 24
            height: 24

            Image {
                anchors.fill: parent
                source: Qt.resolvedUrl("components/icons/control-centre-iconscout-white.png")
                sourceSize.width: 512
                sourceSize.height: 512
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }
    }

    fullRepresentation: Item {
        visible: false
        implicitWidth: 1
        implicitHeight: 1
    }

    PlasmaCore.Dialog {
        id: popup
        type: PlasmaCore.Dialog.PopupMenu
        x: root.screenGeometry.x + root.screenGeometry.width - width - 12
        y: root.screenGeometry.y + 40
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
