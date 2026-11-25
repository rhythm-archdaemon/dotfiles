import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    margins { top: 0; left: 0; right: 0 }
    implicitHeight: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusMd
        color: Theme.bgPanel
        border.width: 2
        border.color: Theme.neonPurple

        Rectangle {
            z: 3
            x: 0
            y: parent.height - 1
            width: parent.width
            height: 1
            color: Theme.neonCyan
            opacity: 0.65
        }

        Rectangle {
            z: 2
            x: 0
            y: -height
            width: parent.width
            height: 1
            color: Theme.neonMagenta
            opacity: 0.18
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: parent.height; duration: 5000; easing.type: Easing.Linear }
                PauseAnimation { duration: 900 }
            }
        }

        // left cluster — workspaces
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Workspaces {
                Layout.preferredWidth: 180
            }
        }

        // center cluster — now playing + cava visualizer
        RowLayout {
            anchors.centerIn: parent
            spacing: 14

            Clock {}

            // issue: Cava instance is not running - so currently commenting this module
            // Cava {}
        }

        // right cluster — brightness, battery, wifi, power
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Battery {}
            Wifi {}
        }
    }
}
