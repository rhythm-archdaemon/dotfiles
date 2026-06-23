import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs

Item {
    id: root
    
    // Explicit bounding to guarantee no parent overflow/shifting
    width: mainRow.implicitWidth
    height: 24
    implicitWidth: width
    implicitHeight: height

    // --- CRITICAL: Bind the Pipewire node ---
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    // --- Raw State ---
    property real brightCurrent: 0
    property real brightMax: 1
    property int volRaw: -1

    // --- Animated Display Values ---
    property real brightDisplay: 0
    property real volDisplay: 0

    readonly property int brightPercent: brightMax > 0 ? Math.round((brightCurrent / brightMax) * 100) : 0
    readonly property int brightPercentDisplay: Math.round(brightDisplay)
    readonly property int volPercentDisplay: Math.round(volDisplay)

    // --- Smooth Animations ---
    Behavior on brightDisplay {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Behavior on volDisplay {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    // --- Volume Binding ---
    onVolRawChanged: {
        if (volRaw >= 0) {
            volDisplay = volRaw
        }
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {}
    }

    Binding {
        target: root
        property: "volRaw"
        value: {
            if (!Pipewire.ready) return -1
            var sink = Pipewire.defaultAudioSink
            if (!sink) return -1
            if (!sink.ready) return -1
            var audio = sink.audio
            if (!audio) return 0
            return Math.round(audio.volume * 100)
        }
    }

    // --- Brightness Poller ---
    Process {
        id: brightQuery
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = this.text.trim().split(",")
                if (fields.length >= 5) {
                    root.brightCurrent = parseFloat(fields[2])
                    root.brightMax = parseFloat(fields[4])
                    root.brightDisplay = root.brightPercent
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            brightQuery.running = false
            brightQuery.running = true
        }
    }

    // --- UI Structure ---
    Row {
        id: mainRow
        // Fixed Layout Shifting: Centered vertically within parent coordinates
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        // Volume Block
        Row {
            spacing: 5
            Text { text: "|"; color: Theme.neonYellow; font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 2 } }
            
            // Fixed Lag: Using one clean, static, high-performance icon
            Text {
                text: "󰕾  " + " " +(root.volPercentDisplay < 0 ? "--" : root.volPercentDisplay + "%")
                color: root.volPercentDisplay < 0 ? Theme.neonRed : Theme.neonYellow
                font { family: Theme.fontFamily; pixelSize: Theme.fontSize; bold: true }
            }
            
        }

        // Structural Partition
        Text {
            text: "|"
            color: Theme.neonYellow
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
        }

        // Brightness Block
        Row {
            spacing: 5
           
            // Fixed Lag: Using one clean, static, high-performance icon
            Text {
                text: "󰃠  " + " " + root.brightPercentDisplay + "%"
                color: Theme.neonYellow
                font { family: Theme.fontFamily; pixelSize: Theme.fontSize; bold: true }
            }
            
            Text { text: "|"; color: Theme.neonYellow; font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 2 } }
        }
    }
}
