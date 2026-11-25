import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
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
            visible: Config.appearance.scanlines
            z: 2
            x: 0
            y: -height
            width: parent.width
            height: 1
            color: Theme.neonMagenta
            opacity: 0.18
            SequentialAnimation on y {
                running: Config.appearance.scanlines
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

            Workspaces {}
        }

        // center cluster — clock (cava / now-playing can go here later)
        RowLayout {
            anchors.centerIn: parent
            spacing: 14

            Clock { visible: Config.bar.showClock }
        }

        // right cluster
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Battery {}
            Wifi { visible: Config.bar.showWifi }
        }
    }
}
