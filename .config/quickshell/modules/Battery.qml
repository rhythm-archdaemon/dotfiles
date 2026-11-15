import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs

Item {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property bool present: !!root.dev && root.dev.isLaptopBattery
    readonly property int percent: Math.round(root.dev.percentage * 100)
    readonly property bool charging: !!root.dev &&
        (root.dev.state === UPowerDeviceState.Charging || root.dev.state === UPowerDeviceState.PendingCharge)
    readonly property bool full: !!root.dev && root.dev.state === UPowerDeviceState.FullyCharged

    readonly property color stateColor: {
        if (!root.present) return Theme.textDim
        if (root.charging || root.full) return Theme.neonGreen
        if (root.percent <= 15) return Theme.neonRed
        if (root.percent <= 50) return Theme.neonOrange
        return Theme.neonCyan
    }

    visible: root.present
    implicitWidth: batteryRow.implicitWidth
    implicitHeight: 24

    RowLayout {
        id: batteryRow
        anchors.fill: parent
        spacing: 5

        Text {
            text: "BAT //"
            color: root.stateColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            font.bold: true
        }
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: {
                if (root.charging) return "󱐥"
                if (root.percent <= 15) return "󰂎"
                if (root.percent <= 35) return "󰁼"
                if (root.percent <= 65) return "󰁾"
                if (root.percent <= 90) return "󰂂"
                return "󰁹"
            }
            color: root.stateColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize

            SequentialAnimation on opacity {
                running: root.present && root.percent <= 15 && !root.charging
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
            }
        }
        Text {
            text: root.percent + "%"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.bold: true
        }
        Text {
            text: root.charging ? "CHG" : ""
            color: root.stateColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            font.bold: true
        }
    }
}
