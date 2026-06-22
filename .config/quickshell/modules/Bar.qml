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
    margins { top: 8; left: 8; right: 8 }
    implicitHeight: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusMd
        color: Theme.bgPanel
        border.width: 1
        border.color: Theme.borderDim

        // left cluster — workspaces
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 18

            Workspaces {}
        }

        // center cluster — now playing + cava visualizer
        RowLayout {
            anchors.centerIn: parent
            spacing: 18

            MediaPlayer {}
            Cava {}
        }

        // right cluster — brightness, battery, wifi, power
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 18

            Brightness {}
            Battery {}
            Wifi {}
            PowerMenu {}
        }
    }
}
