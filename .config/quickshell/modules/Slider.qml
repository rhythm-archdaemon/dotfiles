import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs

Item {
    id: root

    property string kind: "brightness" // "brightness" | "volume"
    property string label: kind === "volume" ? "Volume" : "Brightness"
    property color accent: kind === "volume" ? Theme.neonCyan : Theme.neonYellow

    Layout.fillWidth: true
    implicitWidth: 200
    implicitHeight: content.implicitHeight + 20 // account for margins below

    // --- Brightness backend ---
    property real brightCurrent: 0
    property real brightMax: 1
    readonly property int brightPercent: brightMax > 0 ? Math.round((brightCurrent / brightMax) * 100) : 0

    Process {
        id: brightQuery
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = this.text.trim().split(",")
                if (fields.length >= 5) {
                    root.brightCurrent = parseFloat(fields[2])
                    root.brightMax = parseFloat(fields[4])
                }
            }
        }
    }
    Process { id: brightSet }

    Timer {
        interval: 1000
        running: root.kind === "brightness"
        repeat: true
        triggeredOnStart: true
        onTriggered: { brightQuery.running = false; brightQuery.running = true }
    }

    // --- Volume backend ---
    PwObjectTracker { objects: root.kind === "volume" ? [ Pipewire.defaultAudioSink ] : [] }
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool sinkReady: !!(sink && sink.ready && sink.audio)
    readonly property int volPercent: sinkReady ? Math.round(sink.audio.volume * 100) : 0

    // --- Unified value/commit ---
    readonly property int value: kind === "volume" ? volPercent : brightPercent

    function commit(percent) {
        if (kind === "volume") {
            if (sinkReady)
                sink.audio.volume = percent / 100
        } else {
            brightSet.command = ["brightnessctl", "set", percent + "%"]
            brightSet.running = true
            brightCurrent = (percent / 100) * brightMax
        }
    }

    // Border box around each slider (also reads as a divider when stacked)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: root.accent
        radius: Theme.radiusSm

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
                    text: root.label
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: root.value + "%"
                    color: root.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                }
            }

            Rectangle {
                id: track
                Layout.fillWidth: true
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                height: 6
                radius: 3
                color: Theme.bgCard || Qt.rgba(1, 1, 1, 0.1)

                Rectangle {
                    width: Math.max(0, Math.min(parent.width, parent.width * (root.value / 100)))
                    height: parent.height
                    radius: 3
                    color: root.accent
                }

                Rectangle {
                    x: Math.max(0, Math.min(track.width, track.width * (root.value / 100))) - 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 12
                    height: 12
                    radius: 6
                    color: Theme.textPrimary
                    border.color: root.accent
                    border.width: 1
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -10
                    cursorShape: Qt.PointingHandCursor

                    function apply(item, mouse) {
                        if (track.width <= 0) return;
                        const pos = mapToItem(track, mouse.x, mouse.y)
                        const pct = Math.max(0, Math.min(100, Math.round((pos.x / track.width) * 100)))
                        root.commit(pct)
                    }

                    onPressed: (mouse) => apply(this, mouse)
                    onPositionChanged: (mouse) => { if (pressed) apply(this, mouse) }
                }
            }
        }
    }
}
