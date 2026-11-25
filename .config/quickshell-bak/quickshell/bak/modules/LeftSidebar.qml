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
        clip: true
        radius: Theme.radiusMd
        border.width: 1
        border.color: Theme.neonCyan

        Rectangle {
            z: 3
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 2
            color: Theme.neonCyan
            opacity: 0.8
        }
        Rectangle {
            z: 2
            x: 0
            y: -height
            width: parent.width
            height: 1
            color: Theme.neonCyan
            opacity: 0.18
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: parent.height; duration: 4800; easing.type: Easing.Linear }
                PauseAnimation { duration: 900 }
            }
        }
        Rectangle { z: 3; width: 22; height: 2; x: 8; y: 8; color: Theme.neonCyan }
        Rectangle { z: 3; width: 2; height: 22; x: 8; y: 8; color: Theme.neonCyan }

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
            opacity: leftSidebarWindow.isHovered ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Text {
                Layout.fillWidth: true
                text: "// LEFT RAIL // CORE SYSTEMS"
                color: Theme.neonCyan
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 10
            }

            UserInfo {
                Layout.fillWidth: true
            }

            MediaPlayer { Layout.fillWidth: true }

            Slider { kind: "volume" }
            Slider { kind: "brightness" }

            SystemInfo { Layout.fillWidth: true }

            Item { Layout.fillHeight: true }


        }
    }
}
