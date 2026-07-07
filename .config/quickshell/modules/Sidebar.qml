import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules

PanelWindow {
    id: sidebarWindow
    required property var modelData
    screen: modelData

    anchors { top: true; right: true }
    margins { top: Theme.barHeight; right: 0 }
    implicitHeight: screen.height - Theme.barHeight
    implicitWidth: expandedWidth
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    mask: Region { item: panelBackground }

    // Direct declarative binding: Tracks the HoverHandler status smoothly
    readonly property bool isHovered: sidebarHoverHandler.hovered
    readonly property int collapsedWidth: 6
    readonly property int expandedWidth: 400

    Rectangle {
        id: panelBackground
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: sidebarWindow.isHovered ? sidebarWindow.expandedWidth : sidebarWindow.collapsedWidth
        color: Theme.bgPanel
        radius: Theme.radiusMd

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
            anchors.margins: 20
            anchors.topMargin: 30
            spacing: 28
            opacity: sidebarWindow.isHovered ? 1.0 : 0.0

            Behavior on opacity { NumberAnimation { duration: 150 } }

            Slider { kind: "brightness" }
            Slider { kind: "volume" }
            Item { Layout.fillHeight: true }
            
            PowerRow {
                Layout.fillWidth: true
            }
        }
    }
}
