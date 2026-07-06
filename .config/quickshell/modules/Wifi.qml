import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs

Item {
    id: root
    
    // Explicit sizing securely mapped directly to content layouts
    width: mainLayout.implicitWidth
    height: Theme.barHeight || 30
    
    implicitWidth: width
    implicitHeight: height

    // --- State Properties ---
    property string activeSsid: ""
    property int activeSignal: 0
    readonly property bool isConnected: activeSsid !== ""

    // --- High-Performance Asynchronous Status Polling ---
    Process {
        id: statusProc
        command: ["sh", "-c", "nmcli -t -f active,ssid,signal dev wifi | grep '^yes' | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(":")
                if (parts.length >= 3 && parts[0] === "yes") {
                    root.activeSsid = parts[1]
                    root.activeSignal = parseInt(parts[2]) || 0
                } else {
                    root.activeSsid = ""
                    root.activeSignal = 0
                }
            }
        }
    }

    // Safely intervals background network state checks every 5 seconds without freezing UI frames
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!statusProc.running) {
                statusProc.running = true
            }
        }
    }

    // --- UI Presentation Layer ---
    RowLayout {
        id: mainLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        // Bracket Wrapper Open
        Text {
            text: "["
            color: Theme.neonBlue
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 2 }
        }

        // Minimal Static Clean Icon Block
        Text {
            Layout.alignment: Qt.AlignVCenter
            // Using a single, clean structural icon indicator to completely bypass dynamic string lag loops
            text: root.isConnected ? "󰤨" : "󰤭"
            color: root.isConnected ? Theme.neonBlue : Theme.textDim
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 1 }
        }

        // Network SSID Display Value Block
        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 120
            elide: Text.ElideRight
            
            // Layout styling with explicit fallback strings
            text: root.isConnected ? root.activeSsid : "Offline"
            color: root.isConnected ? Theme.textPrimary : Theme.textDim
            font { 
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true // Bolder text variant applied
            }
        }

        // Bracket Wrapper Close
        Text {
            text: "]"
            color: Theme.neonBlue
            font { family: Theme.fontFamily; pixelSize: Theme.fontSize + 2 }
        }
    }
}
