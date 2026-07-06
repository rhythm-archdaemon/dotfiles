import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs

// Standalone lock / reboot / power-off row. Same commands and Canvas icon
// drawing as modules/PowerMenu.qml, sized for the sidebar.
RowLayout {
    id: root
    spacing: 20

    Process { id: lockProc; command: ["gtklock"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: powerProc; command: ["systemctl", "poweroff"] }

    component PowerIcon: Rectangle {
        id: btn
        property int iconType: 0 // 0: lock, 1: reboot, 2: power
        property color tint: Theme.neonRed
        signal activated()

        width: 36; height: 30
        radius: Theme.radiusSm
        color: mouse.containsMouse ? Qt.rgba(tint.r, tint.g, tint.b, 0.12) : "transparent"
        border.width: 1.5
        border.color: tint
        Behavior on color { ColorAnimation { duration: 150 } }

        Canvas {
            anchors.centerIn: parent
            width: 16; height: 16
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = btn.tint
                ctx.fillStyle = btn.tint
                ctx.lineWidth = 1.8
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                const cx = width / 2, cy = height / 2

                if (btn.iconType === 0) {
                    ctx.strokeRect(2, 7, 12, 8)
                    ctx.beginPath(); ctx.arc(cx, 7, 4, Math.PI, 0); ctx.stroke()
                    ctx.beginPath(); ctx.arc(cx, 11, 1.2, 0, Math.PI * 2); ctx.fill()
                } else if (btn.iconType === 1) {
                    ctx.beginPath(); ctx.arc(cx, cy, 6, -Math.PI * 0.3, Math.PI * 1.5); ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(cx + 2, cy - 8); ctx.lineTo(cx + 6, cy - 4); ctx.lineTo(cx + 1, cy - 3)
                    ctx.fill()
                } else {
                    ctx.beginPath(); ctx.arc(cx, cy + 1, 6, -Math.PI * 0.75, -Math.PI * 0.25, true); ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(cx, cy - 5); ctx.lineTo(cx, cy + 1); ctx.stroke()
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }
    }

    PowerIcon { iconType: 0; tint: Theme.neonCyan; onActivated: lockProc.running = true }
    PowerIcon { iconType: 1; tint: Theme.neonOrange; onActivated: rebootProc.running = true }
    PowerIcon { iconType: 2; tint: Theme.neonRed; onActivated: powerProc.running = true }
}
