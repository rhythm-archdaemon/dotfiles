import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs

Item {
    id: root

    property string activeSsid: ""
    property int activeSignal: 0
    readonly property bool isConnected: activeSsid !== ""

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: 24
    width: implicitWidth
    height: Theme.barHeight || 30

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

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!statusProc.running) statusProc.running = true
        }
    }

    RowLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 5

        Text {
            text: "NET //"
            color: root.isConnected ? Theme.neonBlue : Theme.neonRed
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            font.bold: true
        }
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.isConnected ? "󰤨" : "󰤭"
            color: root.isConnected ? Theme.neonBlue : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.maximumWidth: 120
            elide: Text.ElideRight
            text: root.isConnected ? root.activeSsid : "OFFLINE"
            color: root.isConnected ? Theme.textPrimary : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.bold: true
        }
        Text {
            visible: root.isConnected
            text: root.activeSignal + "%"
            color: Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
        }
    }
}
