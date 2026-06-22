import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs

// Reads UPower's display device directly (reactive — no polling).
// Color: green while charging/full, cyan when healthy, orange mid,
// red + pulsing when low and on battery.
RowLayout {
    id: root
    spacing: 6

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
        if (root.percent <= 35) return Theme.neonOrange
        return Theme.neonCyan
    }

    visible: root.present

    Rectangle {
        id: shell
        Layout.alignment: Qt.AlignVCenter
        width: 26; height: 13
        radius: 3
        color: "transparent"
        border.width: 2
        border.color: root.stateColor

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 2
            height: parent.height - 4
            width: Math.max(2, (parent.width - 4) * (root.percent / 100))
            radius: 1
            color: root.stateColor

            SequentialAnimation on opacity {
                running: root.present && root.percent <= 15 && !root.charging
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
            }
        }

        // battery "nub"
        Rectangle {
            anchors.left: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 2; height: 6
            color: root.stateColor
        }

        Text {
            visible: root.charging
            anchors.centerIn: parent
            text: "\u26A1" // ⚡
            font.pixelSize: 9
            color: Theme.bgVoid
        }
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: root.percent + "%"
        color: root.stateColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
