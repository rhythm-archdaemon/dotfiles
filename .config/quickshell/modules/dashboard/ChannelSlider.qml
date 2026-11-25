import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services

// Percent slider for a system channel. Was Slider.qml; renamed so it can
// never collide with QtQuick.Controls' Slider in a file that imports both.
HudPanel {
    id: root

    property string kind: "brightness"   // "brightness" | "volume"
    property string label: kind === "volume" ? "Volume" : "Brightness"

    Layout.fillWidth: true
    implicitWidth: 200
    implicitHeight: content.implicitHeight + 20

    accent: kind === "volume" ? Theme.neonCyan : Theme.neonYellow
    accent2: accent
    borderColor: accent
    bracketLength: 14
    bracketInset: 7
    bracketTop: 6
    scanDuration: 3600

    readonly property int value: kind === "volume" ? Audio.percent : Brightness.percent

    function commit(percent) {
        if (kind === "volume") Audio.setPercent(percent)
        else Brightness.setPercent(percent)
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "// " + root.label.toUpperCase() + " CHANNEL"
                color: root.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "[ " + root.value + "% ]"
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
            }
        }

        Rectangle {
            id: track
            Layout.fillWidth: true
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            height: 8
            radius: 1
            color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.10)
            border.width: 1
            border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.35)

            Rectangle {
                width: Math.max(0, Math.min(parent.width, parent.width * (root.value / 100)))
                height: parent.height
                radius: 1
                color: root.accent
            }

            Rectangle {
                x: Math.max(0, Math.min(track.width, track.width * (root.value / 100))) - 6
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                height: 14
                radius: 2
                color: Theme.textPrimary
                border.color: root.accent
                border.width: 2
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -10
                cursorShape: Qt.PointingHandCursor

                function apply(mouse) {
                    if (track.width <= 0) return
                    const pos = mapToItem(track, mouse.x, mouse.y)
                    root.commit(Math.max(0, Math.min(100, Math.round((pos.x / track.width) * 100))))
                }

                onPressed: mouse => apply(mouse)
                onPositionChanged: mouse => { if (pressed) apply(mouse) }
            }
        }
    }
}
