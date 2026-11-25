pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Backlight via brightnessctl.
Singleton {
    id: root

    property real current: 0
    property real max: 1
    readonly property int percent: max > 0 ? Math.round((current / max) * 100) : 0

    function setPercent(p) {
        setProc.command = ["brightnessctl", "set", p + "%"]
        setProc.running = true
        current = (p / 100) * max
    }

    Process {
        id: queryProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = this.text.trim().split(",")
                if (fields.length >= 5) {
                    root.current = parseFloat(fields[2])
                    root.max = parseFloat(fields[4])
                }
            }
        }
    }

    Process { id: setProc }

    Timer {
        interval: Config.services.brightnessPollMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            queryProc.running = false
            queryProc.running = true
        }
    }
}
