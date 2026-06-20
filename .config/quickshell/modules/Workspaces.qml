import QtQuick
import Quickshell.Hyprland
import qs

// Small circular workspace indicators (no numbers).
// Filled glowing dot = active workspace.
// Outlined dot       = occupied (has windows) but not focused.
// Faint dim dot       = empty.
// Requires Hyprland. For Sway/i3 swap the Quickshell.Hyprland import
// for Quickshell.I3 and adjust the active/occupied lookups accordingly.
Item {
    id: root
    readonly property int wsCount: 5
    readonly property int gap: 10
    readonly property int maxDot: 16

    implicitWidth: wsCount * maxDot + (wsCount - 1) * gap
    implicitHeight: maxDot

    Repeater {
        model: root.wsCount

        Rectangle {
            id: dot
            required property int index
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool active: !!ws && ws.active
            property bool occupied: !!ws && ws.toplevels.count > 0

            width: active ? root.maxDot : 10
            height: width
            radius: width / 2
            x: index * (root.maxDot + root.gap) + (root.maxDot - width) / 2
            y: (root.implicitHeight - height) / 2

            color: active ? Theme.neonCyan
                 : occupied ? "transparent"
                 : Qt.rgba(1, 1, 1, 0.10)
            border.width: occupied && !active ? 2 : 0
            border.color: Theme.neonCyan

            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            // neon glow ring behind the active dot
            Rectangle {
                visible: dot.active
                anchors.centerIn: parent
                width: parent.width + 10
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 5
                border.color: Qt.rgba(0, 1, 0.95, 0.22)
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -5
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + (dot.index + 1))
            }
        }
    }
}
