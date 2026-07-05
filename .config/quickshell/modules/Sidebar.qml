import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

PanelWindow {
    id: sidebarWindow
    required property var modelData
    screen: modelData

    anchors { top: true; right: true }
    margins { top: Theme.barHeight; right: 0 }
    implicitHeight: screen.height - Theme.barHeight

    // Fixed window size (never resized) — only the inner Rectangle animates.
    implicitWidth: expandedWidth
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    property bool isHovered: false
    readonly property int collapsedWidth: 6
    readonly property int expandedWidth: 320

    Rectangle {
        id: panelBackground
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        width: sidebarWindow.isHovered ? sidebarWindow.expandedWidth : sidebarWindow.collapsedWidth
        color: Theme.bgPanel
        radius: Theme.radiusMd

        Behavior on width {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        Item {
            width: sidebarWindow.expandedWidth
            height: parent.height
            anchors.right: parent.right
            opacity: sidebarWindow.isHovered ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text {
                    text: "QUICKSHELL SIDEBAR"
                    color: Theme.neonMagenta
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: 16
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.neonMagenta
                    opacity: 0.3
                }

                Item { Layout.fillHeight: true }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: sidebarWindow.isHovered = true
            onExited: sidebarWindow.isHovered = false
        }
    }
}
