import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs

// Lightweight wifi control: no NetworkManager D-Bus bindings, just
// three nmcli calls. Click the icon to scan; click a network to
// connect (you'll be prompted for a password if it's secured).
Item {
    id: root
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: 22

    property bool open: false
    property string activeSsid: ""
    property int activeSignal: 0
    property var networks: []

    RowLayout {
        id: rowLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Item {
            Layout.alignment: Qt.AlignVCenter
            width: 16; height: 12

            Repeater {
                model: 3
                Rectangle {
                    required property int index
                    width: 3
                    radius: 1
                    height: 4 + index * 4
                    x: index * 5
                    y: 12 - height
                    color: root.activeSsid ? Theme.neonBlue : Theme.textDim
                    opacity: root.activeSsid && index < Math.ceil((root.activeSignal / 100) * 3) ? 1 : 0.3
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 110
            elide: Text.ElideRight
            text: root.activeSsid || "Offline"
            color: Theme.neonBlue
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        anchors.fill: rowLayout
        anchors.margins: -6
        cursorShape: Qt.PointingHandCursor
        onClicked: { root.open = !root.open; if (root.open) scanProc.running = true }
    }

    // current connection, polled every 5s
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
    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: statusProc.running = true }

    // scan results for the dropdown
    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "yes"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = new Set()
                const list = []
                for (const line of this.text.trim().split("\n")) {
                    const fields = line.split(":")
                    const ssid = fields[0], signal = fields[1], security = fields[2]
                    if (!ssid || seen.has(ssid)) continue
                    seen.add(ssid)
                    list.push({ ssid: ssid, signal: parseInt(signal) || 0, secured: !!security && security !== "--" })
                }
                list.sort((a, b) => b.signal - a.signal)
                root.networks = list
            }
        }
    }

    Process {
        id: connectProc
        command: ["true"]
        stdout: StdioCollector { onStreamFinished: statusProc.running = true }
    }

    function connectTo(ssid, password) {
        connectProc.command = password
            ? ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "dev", "wifi", "connect", ssid]
        connectProc.running = true
    }

    PopupWindow {
        id: popup
        anchor.item: rowLayout
        anchor.edges: Edges.Bottom | Edges.Left
        visible: root.open
        implicitWidth: 270
        implicitHeight: 320
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Theme.bgPanel
            radius: Theme.radiusMd
            border.width: 1
            border.color: Theme.neonBlue

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text { Layout.fillWidth: true; text: "NEARBY NETWORKS"; color: Theme.neonBlue; font.bold: true; font.pixelSize: 11 }
                    Text {
                        text: "\u27F3" // ⟳
                        color: Theme.neonBlue
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: scanProc.running = true }
                    }
                }

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.networks
                    spacing: 4

                    delegate: Rectangle {
                        width: listView.width
                        height: 34
                        radius: Theme.radiusSm
                        color: modelData.ssid === root.activeSsid ? Qt.rgba(0, 0.7, 1, 0.15) : "transparent"
                        border.width: 1
                        border.color: Qt.rgba(0, 0.7, 1, 0.25)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            Text {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: (modelData.secured ? "\uD83D\uDD12 " : "") + modelData.ssid
                                color: Theme.textPrimary
                                font.pixelSize: 12
                            }
                            Text { text: modelData.signal + "%"; color: Theme.neonBlue; font.pixelSize: 11 }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.secured) {
                                    passRow.targetSsid = modelData.ssid
                                    passRow.visible = true
                                    passInput.forceActiveFocus()
                                } else {
                                    root.connectTo(modelData.ssid, "")
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    id: passRow
                    visible: false
                    property string targetSsid: ""
                    Layout.fillWidth: true
                    spacing: 6

                    TextField {
                        id: passInput
                        Layout.fillWidth: true
                        placeholderText: "password for " + passRow.targetSsid
                        echoMode: TextInput.Password
                        onAccepted: { root.connectTo(passRow.targetSsid, text); passRow.visible = false; text = "" }
                    }
                    Text {
                        text: "OK"
                        color: Theme.neonBlue
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { root.connectTo(passRow.targetSsid, passInput.text); passRow.visible = false; passInput.text = "" }
                        }
                    }
                }
            }
        }
    }
}
