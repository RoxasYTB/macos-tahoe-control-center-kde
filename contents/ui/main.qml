pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "components"

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

        mainItem: ControlCenterPanel { }
    }
}
