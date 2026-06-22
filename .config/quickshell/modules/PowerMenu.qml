import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs

RowLayout {
    id: root
    spacing: 12 // Slightly expanded for a cleaner layout

    Process { id: lockProc; command: ["gtklock"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: powerProc; command: ["systemctl", "poweroff"] }

    // --- Smooth Reusable Power Button Template ---
    component PowerButton: Rectangle {
        id: btn
        property int iconType: 0 // 0: Lock, 1: Reboot, 2: Power
        property color tint: Theme.neonRed
        signal activated()

        Layout.alignment: Qt.AlignVCenter
        width: 32; height: 26 // Better proportions for status layouts
        radius: Theme.radiusSm
        
        // Declarative background transition
        color: buttonMouse.containsMouse ? Qt.rgba(tint.r, tint.g, tint.b, 0.12) : "transparent"
        border.width: 1.5
        border.color: tint

        Behavior on color { ColorAnimation { duration: 150 } }

        // Vector Canvas Icon Engine
        Canvas {
            id: iconCanvas
            anchors.centerIn: parent
            width: 14; height: 14

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.strokeStyle = btn.tint;
                ctx.fillStyle = btn.tint;
                ctx.lineWidth = 1.6;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";

                var cx = width / 2;
                var cy = height / 2;

                if (btn.iconType === 0) {
                    // --- Custom Vector Lock Icon ---
                    ctx.strokeRect(2, 6, 10, 7); // Shackle base
                    ctx.beginPath();
                    ctx.arc(cx, 6, 3.5, Math.PI, 0); // Lock shackle loop
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.arc(cx, 9.5, 1, 0, Math.PI * 2); // Keyhole dot
                    ctx.fill();
                } 
                else if (btn.iconType === 1) {
                    // --- Custom Vector Reboot (Rotate) Icon ---
                    ctx.beginPath();
                    ctx.arc(cx, cy, 5, -Math.PI * 0.3, Math.PI * 1.5); // Open circle
                    ctx.stroke();
                    // Arrowhead structure
                    ctx.beginPath();
                    ctx.moveTo(cx + 2, cy - 7);
                    ctx.lineTo(cx + 5, cy - 4);
                    ctx.lineTo(cx + 1, cy - 3);
                    ctx.fill();
                } 
                else if (btn.iconType === 2) {
                    // --- Custom Vector Power Icon ---
                    ctx.beginPath();
                    ctx.arc(cx, cy + 1, 5, -Math.PI * 0.75, -Math.PI * 0.25, true); // Outer arc
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(cx, cy - 4); // Center toggle strike
                    ctx.lineTo(cx, cy + 1);
                    ctx.stroke();
                }
            }
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }
    }

    // --- Layout Deployment ---
    PowerButton {
        iconType: 0 // Lock
        tint: Theme.neonCyan
        onActivated: lockProc.running = true
    }
    PowerButton {
        iconType: 1 // Reboot
        tint: Theme.neonOrange
        onActivated: rebootProc.running = true
    }
    PowerButton {
        iconType: 2 // Power Off
        tint: Theme.neonRed
        onActivated: powerProc.running = true
    }
}
