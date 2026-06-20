import QtQuick
import Quickshell.Io
import qs

// Polls `brightnessctl -m` every 800ms for the true current/max value
// (so the slider always reflects reality, even if brightness was
// changed by a keyboard key outside this widget) and writes new
// values with `brightnessctl set`.
Item {
    id: root
    implicitWidth: 132
    implicitHeight: 22

    property real currentValue: 0
    property real maxValue: 1
    readonly property int percent: maxValue > 0 ? Math.round((currentValue / maxValue) * 100) : 0

    Process {
        id: query
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                // format: device,class,current,percent,max
                const fields = this.text.trim().split(",")
                if (fields.length >= 5) {
                    root.currentValue = parseFloat(fields[2])
                    root.maxValue = parseFloat(fields[4])
                }
            }
        }
    }

    Timer {
        interval: 800
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: query.running = true
    }

    Process {
        id: setter
        command: ["true"]
    }

    function setPercent(p) {
        const clamped = Math.max(1, Math.min(100, Math.round(p)))
        root.currentValue = clamped / 100 * root.maxValue // optimistic UI update
        setter.command = ["brightnessctl", "set", clamped + "%"]
        setter.running = true
    }

    Text {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        text: "\u2600" // ☀
        color: Theme.neonYellow
        font.pixelSize: 13
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: icon.right
        anchors.leftMargin: 6
        anchors.right: parent.right
        height: 6
        radius: 3
        color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
        border.color: Theme.neonYellow

        Rectangle {
            height: parent.height
            radius: 3
            color: Theme.neonYellow
            width: Math.max(4, track.width * (root.percent / 100))

            Rectangle {
                width: 10; height: 10; radius: 5
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                color: Theme.neonYellow
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -7
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => root.setPercent((mouse.x / track.width) * 100)
            onPositionChanged: mouse => { if (pressed) root.setPercent((mouse.x / track.width) * 100) }
        }
    }
}
