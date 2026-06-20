import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Spawns cava in "raw" output mode (see ../cava/config) and renders
// the bar levels it streams to stdout as a small neon equalizer.
Item {
    id: root
    readonly property int barCount: 12
    readonly property int barWidth: 4
    readonly property int barGap: 3
    readonly property int maxLevel: 40 // must match ascii_max_range in cava/config

    property var levels: Array(barCount).fill(0)

    implicitWidth: barCount * (barWidth + barGap) - barGap
    implicitHeight: 26

    Process {
        id: cavaProc
        command: ["cava", "-p", Quickshell.shellDir + "/cava/config"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(";").filter(p => p.length > 0).map(Number)
                if (parts.length === root.barCount)
                    root.levels = parts
            }
        }
    }

    Repeater {
        model: root.barCount

        Rectangle {
            required property int index
            x: index * (root.barWidth + root.barGap)
            width: root.barWidth
            radius: 2
            color: Theme.neonPurple
            height: Math.max(3, (root.levels[index] || 0) / root.maxLevel * root.implicitHeight)
            y: root.implicitHeight - height
            opacity: 0.5 + 0.5 * ((root.levels[index] || 0) / root.maxLevel)

            Behavior on height { NumberAnimation { duration: 55 } }
        }
    }
}
