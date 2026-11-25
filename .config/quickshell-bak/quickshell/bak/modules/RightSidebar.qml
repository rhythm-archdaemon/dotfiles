import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.modules

PanelWindow {
    id: rightSidebarWindow
    required property var modelData
    screen: modelData

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors { top: true; right: true }
    margins { top: Theme.barHeight; right: 0 }
    implicitHeight: screen.height - Theme.barHeight
    implicitWidth: expandedWidth
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: panelBackground }

    // Direct declarative binding: Tracks the HoverHandler status smoothly
    readonly property bool isHovered: sidebarHoverHandler.hovered
    readonly property int collapsedWidth: 1
    readonly property int expandedWidth: 400

    Rectangle {
        id: panelBackground
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: rightSidebarWindow.isHovered ? rightSidebarWindow.expandedWidth : rightSidebarWindow.collapsedWidth
        color: Theme.bgPanel
        clip: true
        radius: Theme.radiusMd
        border.width: 2
        border.color: Theme.neonMagenta

        Rectangle {
            z: 3
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 2
            color: Theme.neonMagenta
            opacity: 0.8
        }
        Rectangle {
            z: 2
            x: 0
            y: -height
            width: parent.width
            height: 1
            color: Theme.neonMagenta
            opacity: 0.18
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: parent.height; duration: 4800; easing.type: Easing.Linear }
                PauseAnimation { duration: 900 }
            }
        }
        Rectangle { z: 3; width: 22; height: 2; anchors.right: parent.right; anchors.rightMargin: 8; y: 8; color: Theme.neonMagenta }
        Rectangle { z: 3; width: 2; height: 22; anchors.right: parent.right; anchors.rightMargin: 8; y: 8; color: Theme.neonMagenta }

        Behavior on width {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        // Fix: Use HoverHandler instead of MouseArea.
        // It passively samples the pointer position without intercepting/filtering child events.
        HoverHandler {
            id: sidebarHoverHandler
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            anchors.topMargin: 18
            spacing: 16
            opacity: rightSidebarWindow.isHovered ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Text {
                Layout.fillWidth: true
                text: "// RIGHT RAIL // NETWORK & ALERTS"
                color: Theme.neonMagenta
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 10
            }

            WifiConnect { Layout.fillWidth: true }

            NotificationPanel { Layout.fillWidth: true }

            Item { Layout.fillHeight: true }

            PowerRow {
                Layout.fillWidth: true
            }
        }
    }
}
