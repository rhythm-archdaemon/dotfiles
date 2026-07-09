import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules

PanelWindow {
    id: rightSidebarWindow
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
    readonly property int collapsedWidth: 1
    readonly property int expandedWidth: 400

    Rectangle {
        id: panelBackground
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: rightSidebarWindow.isHovered ? rightSidebarWindow.expandedWidth : rightSidebarWindow.collapsedWidth
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
            opacity: rightSidebarWindow.isHovered ? 1.0 : 0.0
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
