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
        
        // left cluster — workspaces
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Workspaces {}
            
        }

        // center cluster — now playing + cava visualizer
        RowLayout {
            anchors.centerIn: parent
            spacing: 18

            MediaPlayer {}
            // issue: Cava instance is not running - so currently commenting this module
            // Cava {}
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
