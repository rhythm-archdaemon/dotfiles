import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs

RowLayout {
    id: root
    spacing: 10

    Process { id: lockProc; command: ["gtklock"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: powerProc; command: ["systemctl", "poweroff"] }

    component PowerButton: Rectangle {
        id: btn
        property string label: ""
        property color tint: Theme.neonRed
        signal activated()

        Layout.alignment: Qt.AlignVCenter
        width: 30; height: 22
        radius: Theme.radiusSm
        color: "transparent"
        border.width: 1.5
        border.color: tint

        Text {
            anchors.centerIn: parent
            text: btn.label
            color: btn.tint
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
            onEntered: btn.color = Qt.rgba(btn.tint.r, btn.tint.g, btn.tint.b, 0.15)
            onExited: btn.color = "transparent"
        }
    }

    PowerButton {
        label: "\uD83D\uDD12" // 🔒 lock — runs gtklock
        tint: Theme.neonCyan
        onActivated: lockProc.running = true
    }
    PowerButton {
        label: "\u27F3" // ⟳ reboot
        tint: Theme.neonOrange
        onActivated: rebootProc.running = true
    }
    PowerButton {
        label: "\u23FB" // ⏻ power off
        tint: Theme.neonRed
        onActivated: powerProc.running = true
    }
}
