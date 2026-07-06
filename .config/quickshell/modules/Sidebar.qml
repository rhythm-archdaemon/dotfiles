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
    // Fixed window size (never resized) — only the inner Rectangle animates.
    implicitWidth: expandedWidth
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    // Only let input through the region actually covered by the visible panel,
    // instead of the full (always-320px) window surface.
    mask: Region {
        item: panelBackground
    }

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
                anchors.topMargin: 30
                spacing: 28

                Slider { kind: "brightness" }
                Slider { kind: "volume" }
                Item { Layout.fillHeight: true }
                PowerRow {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }
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
