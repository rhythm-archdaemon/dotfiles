import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules

PanelWindow {
    id: leftSidebarWindow
    required property var modelData
    screen: modelData

    anchors { top: true; left: true }
    margins { top: Theme.barHeight; left: 0 }
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
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: leftSidebarWindow.isHovered ? leftSidebarWindow.expandedWidth : leftSidebarWindow.collapsedWidth
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
            opacity: leftSidebarWindow.isHovered ? 1.0 : 0.0
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
