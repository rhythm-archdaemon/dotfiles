import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

Item {
    id: root

    Layout.fillWidth: true
    height: 52
    implicitWidth: 360
    implicitHeight: height

    RowLayout {
        anchors.fill: parent
        spacing: 8

        Repeater {
            model: [
                { name: "LOCK",     icon: "󰌾", tint: Theme.neonCyan,   exec: () => Power.lock() },
                { name: "REBOOT",   icon: "󰜉", tint: Theme.neonOrange, exec: () => Power.reboot() },
                { name: "SHUTDOWN", icon: "󰐥", tint: Theme.neonRed,    exec: () => Power.poweroff() }
            ]

            delegate: Rectangle {
                id: btn
                required property var modelData
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 2

                color: mouse.containsMouse
                    ? Qt.rgba(modelData.tint.r, modelData.tint.g, modelData.tint.b, 0.14)
                    : Qt.rgba(modelData.tint.r, modelData.tint.g, modelData.tint.b, 0.04)
                border.width: 1.5
                border.color: modelData.tint

                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: btn.modelData.icon
                        color: btn.modelData.tint
                        font { family: Theme.fontFamily; pixelSize: 18; bold: true }
                    }
                    Text {
                        text: "// " + btn.modelData.name
                        color: Theme.textPrimary
                        font { family: Theme.fontFamily; pixelSize: 10; bold: true }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: btn.modelData.exec()
                }
            }
        }
    }
}
