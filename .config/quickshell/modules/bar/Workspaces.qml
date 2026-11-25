import QtQuick
import qs.config
import qs.services

// Numbered workspace indicators driven by niri's event stream.
//   active   -> bright, scaled, underlined
//   occupied -> primary text color
//   empty    -> dim
Item {
    id: root
    readonly property int wsCount: Config.bar.workspaceCount
    readonly property int gap: 2

    implicitWidth: wsCount * 18 + (wsCount - 1) * gap
    implicitHeight: 24

    Repeater {
        model: root.wsCount

        Rectangle {
            id: dot
            required property int index
            property var ws: Niri.wsAtIdx(index + 1)
            property bool active: !!ws && ws.active
            property bool occupied: !!ws && ws.occupied

            width: 18
            height: 20
            x: index * (width + root.gap)
            y: (root.implicitHeight - height) / 2 + 2
            color: "transparent"
            border.width: 0

            Text {
                anchors.centerIn: parent
                // lift slightly to make room for the underline
                anchors.verticalCenterOffset: dot.active ? -2 : 0
                scale: dot.active ? 1.25 : 1.0
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                text: dot.index + 1
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: dot.active
                color: dot.active ? Theme.neonCyan
                    : dot.occupied ? Theme.textPrimary
                    : Theme.textDim
            }

            Rectangle {
                visible: dot.active
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: dot.active ? 12 : 0
                height: 2
                radius: 1
                color: Theme.neonCyan
                opacity: 0.95
                Behavior on width { NumberAnimation { duration: 160 } }

                SequentialAnimation on opacity {
                    running: dot.active
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.35; duration: 700 }
                    NumberAnimation { to: 1.0; duration: 700 }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Niri.focusWorkspace(dot.index + 1)
            }
        }
    }
}
