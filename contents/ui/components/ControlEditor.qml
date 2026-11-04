import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtCore
import Tahoe.ControlCenter.Native 1.0

Window {
    id: root
    width: Math.min(735, Screen.width - 48)
    height: Math.min(900, Screen.height - 48)
    minimumWidth: 650
    minimumHeight: 600
    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    title: qsTr("Edit Controls")
    property string selectedCategory: "All Controls"
    property string searchText: ""
    property var draftControlCenterItems: []
    property var draftMenuBarItems: []
    property bool applyingChanges: false
    property bool showAssignmentEditor: false
    signal editorClosed()

    Settings {
        id: savedLayout
        category: "ControlCenter"
        property var controlCenterItems: ["AirDrop", "Bluetooth", "Wi-Fi", "Stage Manager", "Screen Mirroring", "Appearance", "Screenshot", "Focus", "Display", "Sound", "Now Playing"]
        property var menuBarItems: []
    }

    readonly property var categories: [
        "All Controls", "Battery", "Clock", "Connectivity", "Desktop & Finder",
        "Display & Brightness", "Fast User Switching", "Focus", "Home", "Keyboards",
        "Lock Screen", "Microsoft Teams", "Notes", "Now Playing", "Screenshot",
        "Shortcuts", "Sounds", "Utilities"
    ]
    readonly property var catalog: [
        {name:"Scene or Accessory", category:"Suggestions", icon:"✦", shape:"large"},
        {name:"Alarm", category:"Suggestions", icon:"◴", shape:"circle"},
        {name:"Stopwatch", category:"Suggestions", icon:"◉", shape:"circle"},
        {name:"Tile Windows Left & Right", category:"Suggestions", icon:"◧", shape:"pill"},
        {name:"Run Shortcut", category:"Suggestions", icon:"◆", shape:"pill"},
        {name:"Voice Memo", category:"Suggestions", icon:"▥", shape:"circle"},
        {name:"Quick Note", category:"Suggestions", icon:"▧", shape:"circle"},
        {name:"Recognize Music", category:"Suggestions", icon:"♫", shape:"pill"},
        {name:"Start Screen Saver", category:"Suggestions", icon:"☼", shape:"large"},
        {name:"Battery", category:"Battery", icon:"▰", shape:"pill"},
        {name:"Alarm", category:"Clock", icon:"◴", shape:"circle"},
        {name:"Stopwatch", category:"Clock", icon:"◉", shape:"circle"},
        {name:"Timer", category:"Clock", icon:"◌", shape:"circle"},
        {name:"AirDrop", category:"Connectivity", icon:"⌁", shape:"pill"},
        {name:"Bluetooth", category:"Connectivity", icon:"ᛒ", shape:"pill"},
        {name:"Wi-Fi", category:"Connectivity", icon:"◉", shape:"pill"},
        {name:"Application Windows", category:"Desktop & Finder", icon:"⊞", shape:"circle"},
        {name:"Dock Auto-hide", category:"Desktop & Finder", icon:"⇧", shape:"circle"},
        {name:"Mission Control", category:"Desktop & Finder", icon:"▱", shape:"circle"},
        {name:"Show Desktop", category:"Desktop & Finder", icon:"▣", shape:"circle"},
        {name:"Stage Manager", category:"Desktop & Finder", icon:"▤", shape:"circle"},
        {name:"Tile Windows Left & Corners", category:"Desktop & Finder", icon:"◧", shape:"circle"},
        {name:"Tile Windows Left & Right", category:"Desktop & Finder", icon:"◫", shape:"circle"},
        {name:"Tile Windows to Corners", category:"Desktop & Finder", icon:"⊞", shape:"circle"},
        {name:"Dark Mode", category:"Display & Brightness", icon:"◐", shape:"circle"},
        {name:"Display", category:"Display & Brightness", icon:"☼", shape:"pill"},
        {name:"Screen Mirroring", category:"Display & Brightness", icon:"▢", shape:"circle"},
        {name:"Fast User Switching", category:"Fast User Switching", icon:"◎", shape:"circle"},
        {name:"Focus", category:"Focus", icon:"☾", shape:"pill"},
        {name:"Home", category:"Home", icon:"⌂", shape:"circle"},
        {name:"Keyboard Brightness", category:"Keyboards", icon:"⌨", shape:"pill"},
        {name:"Lock Screen", category:"Lock Screen", icon:"▣", shape:"circle"},
        {name:"Microsoft Teams", category:"Microsoft Teams", icon:"T", shape:"pill"},
        {name:"Notes", category:"Notes", icon:"▤", shape:"circle"},
        {name:"Now Playing", category:"Now Playing", icon:"♫", shape:"pill"},
        {name:"Screenshot", category:"Screenshot", icon:"◎", shape:"circle"},
        {name:"Shortcuts", category:"Shortcuts", icon:"◆", shape:"pill"},
        {name:"Sound", category:"Sounds", icon:"◖", shape:"pill"},
        {name:"Utilities", category:"Utilities", icon:"⚒", shape:"circle"}
    ]

    function matches(entry) {
        const term = searchText.trim().toLowerCase()
        return (!term || entry.name.toLowerCase().indexOf(term) >= 0 || entry.category.toLowerCase().indexOf(term) >= 0)
            && (selectedCategory === "All Controls" || selectedCategory === entry.category || entry.category === "Suggestions")
    }
    function catalogIcon(name) {
        if (name === "Scene or Accessory" || name === "Home") return "cupertino-font-house_fill"
        if (["Alarm", "Stopwatch", "Timer"].indexOf(name) >= 0) return "cupertino-font-clock"
        if (name.indexOf("Tile Windows") === 0 || name === "Application Windows" || name === "Mission Control" || name === "Dock Auto-hide") return "stage-manager"
        if (name === "Show Desktop" || name === "Screen Mirroring") return "screen-mirroring"
        if (name === "Run Shortcut" || name === "Shortcuts" || name === "Fast User Switching" || name === "Microsoft Teams") return "cupertino-font-square_grid_2x2_fill"
        if (name === "Voice Memo") return "cupertino-font-waveform"
        if (name === "Quick Note" || name === "Notes") return "note"
        if (name === "Recognize Music" || name === "Now Playing") return "cupertino-font-music_note"
        if (name === "Start Screen Saver") return "moon"
        if (name === "Battery") return "cupertino-font-battery_100"
        if (name === "AirDrop") return "airdrop-muted"
        if (name === "Bluetooth") return "cupertino-font-bluetooth"
        if (name === "Wi-Fi") return "cupertino-font-wifi"
        if (name === "Dark Mode") return "appearance"
        if (name === "Display") return "brightness-high"
        if (name === "Focus") return "cupertino-font-moon_fill"
        if (name === "Keyboard Brightness") return "cupertino-font-keyboard"
        if (name === "Lock Screen") return "cupertino-font-lock_fill"
        if (name === "Screenshot") return "screenshot"
        if (name === "Sound") return "cupertino-font-speaker_3_fill"
        if (name === "Utilities") return "cupertino-font-wrench_fill"
        return "cupertino-font-square_grid_2x2_fill"
    }
    function catalogStatus(name) {
        const controller = typeof systemControls !== "undefined" ? systemControls : null
        if (name === "Wi-Fi") {
            if (!controller || !controller.wifiAvailable) return qsTr("Unavailable")
            if (!controller.wifiEnabled) return qsTr("Off")
            return controller.wifiNetworkName.length ? controller.wifiNetworkName : qsTr("On")
        }
        if (name === "Bluetooth") {
            if (!controller || !controller.bluetoothAvailable) return qsTr("Unavailable")
            return controller.bluetoothEnabled ? qsTr("On") : qsTr("Off")
        }
        if (name === "Battery") {
            if (!controller || !controller.batteryAvailable) return qsTr("Unavailable")
            return controller.batteryPercent + " %"
        }
        if (name === "AirDrop") return qsTr("Unavailable")
        return ""
    }
    function categoryIcon(name) {
        if (name === "All Controls") return "cupertino-font-square_grid_2x2_fill"
        if (name === "Battery") return "cupertino-font-battery_100"
        if (name === "Clock") return "cupertino-font-clock"
        if (name === "Connectivity") return "cupertino-font-wifi"
        if (name === "Desktop & Finder") return "stage-manager"
        if (name === "Display & Brightness") return "brightness-high"
        if (name === "Focus") return "cupertino-font-moon_fill"
        if (name === "Home") return "cupertino-font-house_fill"
        if (name === "Keyboards") return "cupertino-font-keyboard"
        if (name === "Lock Screen") return "cupertino-font-lock_fill"
        if (name === "Notes") return "note"
        if (name === "Now Playing") return "cupertino-font-music_note"
        if (name === "Screenshot") return "screenshot"
        if (name === "Sounds") return "cupertino-font-speaker_3_fill"
        if (name === "Utilities") return "cupertino-font-wrench_fill"
        return "cupertino-font-square_grid_2x2_fill"
    }
    function addTo(target, name) {
        let list = target === "menu" ? draftMenuBarItems.slice() : draftControlCenterItems.slice()
        if (list.indexOf(name) < 0) list.push(name)
        if (target === "menu") draftMenuBarItems = list
        else draftControlCenterItems = list
    }
    function removeFrom(target, name) {
        let list = target === "menu" ? draftMenuBarItems.slice() : draftControlCenterItems.slice()
        const i = list.indexOf(name)
        if (i >= 0) list.splice(i, 1)
        if (target === "menu") draftMenuBarItems = list
        else draftControlCenterItems = list
    }
    function moveWithin(target, name, beforeName) {
        let list = target === "menu" ? draftMenuBarItems.slice() : draftControlCenterItems.slice()
        const from = list.indexOf(name)
        const to = list.indexOf(beforeName)
        if (from < 0 || to < 0 || from === to) return
        list.splice(from, 1)
        list.splice(list.indexOf(beforeName), 0, name)
        if (target === "menu") draftMenuBarItems = list
        else draftControlCenterItems = list
    }
    function applyAndClose() {
        savedLayout.controlCenterItems = draftControlCenterItems.slice()
        savedLayout.menuBarItems = draftMenuBarItems.slice()
        if (typeof trayController !== "undefined")
            trayController.setMenuBarItems(draftMenuBarItems.join("\n"))
        applyingChanges = true
        close()
    }
    function showEditor() {
        draftControlCenterItems = savedLayout.controlCenterItems.slice()
        draftMenuBarItems = savedLayout.menuBarItems.slice()
        applyingChanges = false
        showAssignmentEditor = false
        x = Math.round((Screen.width - width) / 2)
        y = Math.round((Screen.height - height) / 2)
        show()
        raise()
        requestActivate()
    }
    onClosing: editorClosed()

    BlurBehindRegion {
        window: root
        maskSource: Qt.resolvedUrl("qrc:/app/control-editor-blur-window-region.png")
        alphaThreshold: 24
        enabled: true
    }

    Shortcut { sequence: "Escape"; onActivated: root.close() }

    Rectangle {
        anchors.fill: parent
        radius: 30
        color: "#dd311b43"
        border.color: "#70d5b8fa"
        border.width: 1
        clip: true

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // Category rail: independently scrollable, with the exact order
            // visible in the supplied Tahoe editor capture.
            Rectangle {
                Layout.preferredWidth: 244
                Layout.fillHeight: true
                color: "#20202b"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 9
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 34; radius: 17
                        color: "#332d37"
                        border.color: "#8964ff"
                        border.width: 2
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 10
                            Text { text: "⌕"; color: "#aaa4b6"; font.pixelSize: 21 }
                            TextField {
                                id: search
                                Layout.fillWidth: true
                                text: root.searchText
                                onTextChanged: root.searchText = text
                                placeholderText: qsTr("Search Controls")
                                color: "white"
                                placeholderTextColor: "#aaa4b6"
                                font.pixelSize: 13
                                background: Item {}
                            }
                        }
                    }
                    ScrollView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        clip: true
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        // The reference has a single vertical rail here. Qt's
                        // default horizontal bar otherwise appears for a few
                        // sub-pixel Flow overflows and steals height from the
                        // last visible category rows.
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        Column {
                            width: parent.width
                            spacing: 3
                            Repeater {
                                model: root.categories
                                delegate: Rectangle {
                                    required property string modelData
                                    required property int index
                                    width: parent.width; height: 43; radius: 10
                                    color: root.selectedCategory === modelData ? "#914ac0" : "transparent"
                                    Row {
                                        anchors.fill: parent; anchors.leftMargin: 12; spacing: 11
                                        Rectangle {
                                            width: 27; height: 27; radius: 7
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: ["#8b55cf", "#35b867", "#746a7c", "#2789ee", "#35353b", "#2489ee", "#8b8b91", "#8158ed", "#f7a916", "#96969c", "#202024", "#5869d8", "#f4f0e8", "#ff496e", "#74747b", "#9d54d2", "#eb405b", "#85858c"][index]
                                            MacIcon {
                                                anchors.centerIn: parent
                                                width: 18; height: 18
                                                iconName: root.categoryIcon(modelData)
                                                glyphColor: "white"
                                            }
                                        }
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData; color: "#f5f0fa"; font.pixelSize: 13
                                        }
                                    }
                                    TapHandler { onTapped: root.selectedCategory = modelData }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: "#50d6c6dd" }

            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                spacing: 0
                ScrollView {
                    id: catalogScroll
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    Column {
                        width: catalogScroll.availableWidth
                        leftPadding: 20; rightPadding: 20; topPadding: 18; bottomPadding: 14
                        spacing: 8

                        Repeater {
                            model: root.selectedCategory === "All Controls" ? ["Suggestions", "Battery", "Clock", "Connectivity", "Desktop & Finder", "Display & Brightness", "Fast User Switching", "Focus", "Home", "Keyboards", "Lock Screen", "Microsoft Teams", "Notes", "Now Playing", "Screenshot", "Shortcuts", "Sounds", "Utilities"] : [root.selectedCategory]
                            delegate: Column {
                                required property string modelData
                                width: parent.width
                                spacing: 10
                                visible: sectionItems.count > 0
                                Text {
                                    width: parent.width; height: 21
                                    text: modelData; color: "#d1b4e9"; font.pixelSize: 12; font.weight: Font.DemiBold
                                }
                                Flow {
                                    id: sectionFlow
                                    width: parent.width
                                    spacing: 12
                                    Repeater {
                                        id: sectionItems
                                        model: root.catalog.filter(function(e) { return e.category === modelData && root.matches(e) })
                                        delegate: Item {
                                            id: tile
                                            required property var modelData
                                            width: modelData.shape === "circle" ? 62 : 138
                                            height: modelData.shape === "large" ? 100 : 99
                                            Column {
                                                anchors.fill: parent; spacing: 5
                                                Item {
                                                    width: tile.modelData.shape === "circle" ? 62 : 138
                                                    height: tile.modelData.shape === "large" ? 74 : 62
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    Rectangle {
                                                        anchors.fill: parent
                                                        radius: tile.modelData.shape === "pill" ? height / 2 : (tile.modelData.shape === "circle" ? width / 2 : 28)
                                                        color: tile.modelData.shape === "large" ? "#851187" :
                                                            tile.modelData.category === "Connectivity" ? "#59417d" :
                                                            tile.modelData.category === "Display & Brightness" ? "#682390" :
                                                            tile.modelData.category === "Fast User Switching" ? "#38558d" : "#941081"
                                                        border.color: "#42d687ee"; border.width: 1
                                                        RowLayout {
                                                            anchors.fill: parent
                                                            anchors.leftMargin: tile.modelData.shape === "pill" ? 8 : 0
                                                            anchors.rightMargin: tile.modelData.shape === "pill" ? 7 : 0
                                                            spacing: 7
                                                            visible: tile.modelData.shape === "pill"
                                                            Item {
                                                                Layout.preferredWidth: 37; Layout.preferredHeight: 37
                                                                Rectangle {
                                                                    anchors.fill: parent
                                                                    radius: width / 2
                                                                    color: ["Wi-Fi", "Bluetooth"].indexOf(tile.modelData.name) >= 0 ? "white"
                                                                        : tile.modelData.name === "AirDrop" ? "#405d6876" : "transparent"
                                                                }
                                                                MacIcon {
                                                                    anchors.centerIn: parent
                                                                    width: 22; height: 22
                                                                    iconName: root.catalogIcon(tile.modelData.name)
                                                                    glyphColor: ["Wi-Fi", "Bluetooth"].indexOf(tile.modelData.name) >= 0 ? "#1687f8" : "white"
                                                                }
                                                            }
                                                            ColumnLayout {
                                                                Layout.fillWidth: true
                                                                spacing: 1
                                                                Text {
                                                                    Layout.fillWidth: true
                                                                    text: tile.modelData.name
                                                                    color: "white"; font.pixelSize: 11; font.weight: Font.DemiBold
                                                                    elide: Text.ElideRight
                                                                }
                                                                Text {
                                                                    Layout.fillWidth: true
                                                                    visible: ["Wi-Fi", "Bluetooth", "AirDrop", "Battery"].indexOf(tile.modelData.name) >= 0
                                                                    text: root.catalogStatus(tile.modelData.name)
                                                                    color: "#e4dbea"; font.pixelSize: 9
                                                                    elide: Text.ElideRight
                                                                }
                                                            }
                                                        }
                                                        MacIcon {
                                                            anchors.centerIn: parent
                                                            width: tile.modelData.shape === "large" ? 28 : 25
                                                            height: tile.modelData.shape === "large" ? 28 : 25
                                                            visible: tile.modelData.shape !== "pill"
                                                            iconName: root.catalogIcon(tile.modelData.name)
                                                            glyphColor: "white"
                                                        }
                                                    }
                                                }
                                                Text {
                                                    width: parent.width; height: 31
                                                    text: tile.modelData.name; color: "#fffaff"; font.pixelSize: 11
                                                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignTop
                                                    wrapMode: Text.WordWrap
                                                }
                                            }
                                            Drag.active: dragHandler.active
                                            Drag.hotSpot.x: width / 2
                                            Drag.hotSpot.y: 30
                                            Drag.keys: ["text/plain"]
                                            Drag.mimeData: ({ "text/plain": tile.modelData.name })
                                            Drag.dragType: Drag.Automatic
                                            DragHandler { id: dragHandler; acceptedButtons: Qt.LeftButton; target: null }
                                            TapHandler { onTapped: root.addTo("control", tile.modelData.name) }
                                            ToolTip.visible: dragHandler.active
                                            ToolTip.text: qsTr("Drag to Control Center or Menu Bar")
                                            Accessible.name: tile.modelData.name
                                            Accessible.role: Accessible.Button
                                        }
                                    }
                                }
                                Rectangle { width: parent.width; height: 1; color: "#42ded0eb" }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: root.showAssignmentEditor
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.showAssignmentEditor ? 56 : 0
                    color: "#251e405f"
                    ColumnLayout {
                        anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 18; spacing: 3
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: qsTr("Control Center"); color: "#dbc5ea"; font.pixelSize: 10; font.weight: Font.DemiBold }
                            Flickable {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                contentWidth: ccRow.implicitWidth; clip: true
                                Row {
                                    id: ccRow; height: parent.height; spacing: 5
                                    Repeater {
                                        model: root.draftControlCenterItems
                                        delegate: Rectangle {
                                            id: ccChip
                                            required property string modelData
                                            required property int index
                                            width: Math.min(100, ccLabel.implicitWidth + 28); height: 23; radius: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: "#4d8b48b6"
                                            Text { id: ccLabel; anchors.centerIn: parent; text: ccChip.modelData + " ×"; color: "white"; font.pixelSize: 9 }
                                            Drag.active: ccDrag.active
                                            Drag.dragType: Drag.Automatic
                                            Drag.keys: ["selected-control"]
                                            Drag.mimeData: ({ "text/plain": ccChip.modelData,
                                                              "application/x-tahoe-selected-control": ccChip.modelData })
                                            DragHandler { id: ccDrag; target: null }
                                            TapHandler { onTapped: root.removeFrom("control", ccChip.modelData) }
                                            DropArea {
                                                anchors.fill: parent; keys: ["selected-control", "text/plain"]
                                                onDropped: function(drop) {
                                                    if (!drop.hasText) return
                                                    if (drop.formats.indexOf("application/x-tahoe-selected-control") >= 0)
                                                        root.moveWithin("control", drop.text, ccChip.modelData)
                                                    else
                                                        root.addTo("control", drop.text)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: qsTr("Menu Bar"); color: "#dbc5ea"; font.pixelSize: 10; font.weight: Font.DemiBold }
                            Flickable {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                contentWidth: mbRow.implicitWidth; clip: true
                                Row {
                                    id: mbRow; height: parent.height; spacing: 5
                                    Repeater {
                                model: root.draftMenuBarItems
                                        delegate: Rectangle {
                                            id: mbChip
                                            required property string modelData
                                            width: Math.min(90, mbLabel.implicitWidth + 28); height: 22; radius: 11
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: "#4d3766a5"
                                            Text { id: mbLabel; anchors.centerIn: parent; text: mbChip.modelData + " ×"; color: "white"; font.pixelSize: 9 }
                                            Drag.active: mbDrag.active
                                            Drag.dragType: Drag.Automatic
                                            Drag.keys: ["selected-menu-control"]
                                            Drag.mimeData: ({ "text/plain": mbChip.modelData,
                                                              "application/x-tahoe-selected-menu-control": mbChip.modelData })
                                            DragHandler { id: mbDrag; target: null }
                                            TapHandler { onTapped: root.removeFrom("menu", mbChip.modelData) }
                                            DropArea {
                                                anchors.fill: parent; keys: ["selected-menu-control", "text/plain"]
                                                onDropped: function(drop) {
                                                    if (!drop.hasText) return
                                                    if (drop.formats.indexOf("application/x-tahoe-selected-menu-control") >= 0)
                                                        root.moveWithin("menu", drop.text, mbChip.modelData)
                                                    else
                                                        root.addTo("menu", drop.text)
                                                }
                                            }
                                        }
                                    }
                                    DropArea {
                                        width: 45; height: parent.height; keys: ["text/plain"]
                                        onDropped: function(drop) { if (drop.hasText) root.addTo("menu", drop.text) }
                                    }
                                }
                            }
                            DropArea {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                keys: ["text/plain"]
                                onDropped: function(drop) { if (drop.hasText) root.addTo("menu", drop.text) }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 68
                    color: "#211d3d61"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 18
                        Text {
                            id: layoutHint
                            Layout.fillWidth: true
                            text: root.showAssignmentEditor
                                ? qsTr("Click a selected control to remove it; drag to reorder…")
                                : qsTr("Drag a control to place it in Control Center or Menu Bar…")
                            color: layoutHintHover.hovered ? "#e8d2ff" : "#fffaff"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Accessible.role: Accessible.Button
                            Accessible.name: qsTr("Show or hide selected control layouts")
                            HoverHandler { id: layoutHintHover }
                            TapHandler { onTapped: root.showAssignmentEditor = !root.showAssignmentEditor }
                            ToolTip.visible: layoutHintHover.hovered
                            ToolTip.delay: 700
                            ToolTip.text: qsTr("Click to manage selected controls")
                        }
                        Button {
                            id: doneButton
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 28
                            text: qsTr("Done")
                            onClicked: root.applyAndClose()
                            background: Rectangle { radius: 15; color: "#4783ff" }
                            contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 12; font.weight: Font.DemiBold; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                }
            }
        }
    }
}
