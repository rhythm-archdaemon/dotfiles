import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs

RowLayout {
    id: root
    spacing: 6

    // --- UPower Backend Reactive Properties ---
    readonly property var dev: UPower.displayDevice
    readonly property bool present: !!root.dev && root.dev.isLaptopBattery
    readonly property int percent: Math.round(root.dev.percentage * 100)
    
    readonly property bool charging: !!root.dev &&
        (root.dev.state === UPowerDeviceState.Charging || root.dev.state === UPowerDeviceState.PendingCharge)
    readonly property bool full: !!root.dev && root.dev.state === UPowerDeviceState.FullyCharged

    // --- High-Accuracy Theme Color Mapping ---
    readonly property color stateColor: {
        if (!root.present) return Theme.textDim
        if (root.charging || root.full) return Theme.neonGreen
        if (root.percent <= 15) return Theme.neonRed
        if (root.percent <= 50) return Theme.neonOrange // Aligned to multi-tier battery theme rules
        return Theme.neonCyan
    }

    visible: root.present

    // Bracket Wrapper Open
    Text {
        text: "["
        color: root.stateColor
        font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 2 }
    }

    // High-Performance Text Icon Block
    Text {
        Layout.alignment: Qt.AlignVCenter
        text: {
            if (root.charging) return "󱐥" // Charging Bolt
            if (root.percent <= 15) return "󰂎" // Critical Low
            if (root.percent <= 35) return "󰁼" // Mid Low
            if (root.percent <= 65) return "󰁾" // Mid Balanced
            if (root.percent <= 90) return "󰂂" // High Healthy
            return "󰁹" // Full
        }
        color: root.stateColor
        font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 1 }

        // Low Battery Soft Warning Glow Effect (Pulse animation from original logic preserved via text layer)
        SequentialAnimation on opacity {
            running: root.present && root.percent <= 15 && !root.charging
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
            NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
        }
    }

    // Typography Percentage Display Block
    Text {
        Layout.alignment: Qt.AlignVCenter
        text: root.percent + "%"
        color: root.stateColor
        font { 
            family: Theme.fontFamily
            pixelSize: Theme.fontSize
            bold: true // Bolder weight applied natively
        }
    }

    // Bracket Wrapper Close
    Text {
        text: "]"
        color: root.stateColor
        font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 2 }
    }
}
