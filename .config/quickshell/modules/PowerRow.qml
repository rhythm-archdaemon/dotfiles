import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs

Item {
    id: root
    
    // Simple logic: Give it explicit sizing constraints just like the Sliders
    Layout.fillWidth: true
    height: 46 
    implicitWidth: 360
    implicitHeight: height

    Process { id: lockProc; command: ["gtklock"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: powerProc; command: ["systemctl", "poweroff"] }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Repeater {
            model: [
                { name: "LOCK",    icon: "󰌾", tint: Theme.neonCyan,   exec: () => lockProc.running = true },
                { name: "REBOOT",  icon: "󰜉", tint: Theme.neonOrange, exec: () => rebootProc.running = true },
                { name: "SHUTDOWN",icon: "󰐥", tint: Theme.neonRed,    exec: () => powerProc.running = true }
            ]

            delegate: Rectangle {
                id: btn
                Layout.fillWidth: true
                Layout.fillHeight: true // Fills the 46px parent height safely
                radius: Theme.radiusSm || 4
                
                color: mouse.containsMouse ? Qt.rgba(modelData.tint.r, modelData.tint.g, modelData.tint.b, 0.12) : "transparent"
                border.width: 1.5
                border.color: modelData.tint

                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: modelData.icon
                        color: modelData.tint
                        font { family: Theme.fontFamily; pixelSize: 18; bold: true }
                    }

                    Text {
                        text: modelData.name
                        color: Theme.textPrimary
                        font { family: Theme.fontFamily; pixelSize: 12; bold: true }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.exec()
                }
            }
        }
    }
}
