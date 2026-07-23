import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell.Wayland
import qs

// Standalone wifi module. Lists top 15 SSIDs (connected network pinned to
// top), each with a Connect button; pressing it reveals an inline password
// row. "+ ADD NETWORK" opens a manual SSID/password entry container.
Item {
    id: root

    Layout.fillWidth: true
    property real containerHeight: 260
    implicitHeight: containerHeight

    property var networks: []
    property string expandedSsid: ""
    property bool addingNetwork: false

    // Statically OnDemand rather than toggled live — flipping keyboardFocus
    // at the exact moment a field opens is a known trigger for niri getting
    // stuck between focus targets. OnDemand alone doesn't steal focus; it
    // just makes the surface eligible, so leaving it on permanently is safe.
    Component.onCompleted: {
        const win = root.Window.window
        if (win && win.WlrLayershell)
            win.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        scanProc.running = true
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,ACTIVE", "dev", "wifi", "list", "--rescan", "yes"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = new Set()
                const list = []
                for (const line of this.text.trim().split("\n")) {
                    const f = line.split(":")
                    if (!f[0] || seen.has(f[0])) continue
                    seen.add(f[0])
                    list.push({ ssid: f[0], signal: parseInt(f[1]) || 0, secured: !!f[2] && f[2] !== "--", active: f[3] === "yes" })
                }
                list.sort((a, b) => (a.active !== b.active) ? (a.active ? -1 : 1) : b.signal - a.signal)
                root.networks = list.slice(0, 15)
            }
        }
    }

    Process { id: connectProc }

    function connectTo(ssid, password) {
        connectProc.command = password ? ["nmcli", "dev", "wifi", "connect", ssid, "password", password] : ["nmcli", "dev", "wifi", "connect", ssid]
        connectProc.running = true
        expandedSsid = ""
        addingNetwork = false
    }

    // Reusable small button used everywhere below (Connect / OK / Close).
    component ActionBtn: Rectangle {
        id: btn
        property string label: ""
        property color tint: Theme.neonGreen
        property bool enabled: true
        signal activated()

        implicitWidth: lbl.implicitWidth + 20
        implicitHeight: 26
        radius: 3
        opacity: enabled ? 1 : 0.5
        color: mouse.containsMouse && enabled ? tint : "transparent"
        border.width: 1
        border.color: tint
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            id: lbl
            anchors.centerIn: parent
            text: btn.label
            color: mouse.containsMouse && btn.enabled ? Theme.bgPanel : btn.tint
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 11
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: btn.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }
    }

    component ThemedField: TextField {
        color: Theme.textPrimary
        placeholderTextColor: Theme.textPrimary
        font.family: Theme.fontFamily
        background: Rectangle {
            radius: 3
            color: Theme.bgPanel
            border.width: 1
            border.color: Theme.neonGreen
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 5
        color: "transparent"
        border.width: 1
        border.color: Theme.neonBlue

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text { text: "WIFI NETWORKS"; color: Theme.neonBlue; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 12 }
                Item { Layout.fillWidth: true }
                ActionBtn {
                    label: "+ ADD NETWORK"; tint: Theme.neonGreen
                    onActivated: {
                        addingNetwork = !addingNetwork
                        expandedSsid = ""
                        if (addingNetwork) Qt.callLater(() => newSsidField.forceActiveFocus())
                    }
                }
                ActionBtn {
                    label: "󰜉"; tint: Theme.neonPurple
                    onActivated: scanProc.running = true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                visible: addingNetwork
                implicitHeight: visible ? addContent.implicitHeight + 20 : 0
                radius: 3
                color: Theme.bgCard
                border.width: 1
                border.color: Theme.neonGreen

                ColumnLayout {
                    id: addContent
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    ThemedField { id: newSsidField; Layout.fillWidth: true; placeholderText: "network name (SSID)"; placeholderTextColor: Theme.textPrimary }
                    ThemedField { id: newPassField; Layout.fillWidth: true; placeholderText: "password"; echoMode: TextInput.Password; placeholderTextColor: Theme.textPrimary }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Item { Layout.fillWidth: true }
                        ActionBtn {
                            label: "CONNECT"; tint: Theme.neonGreen
                            onActivated: { connectTo(newSsidField.text, newPassField.text); newSsidField.text = ""; newPassField.text = "" }
                        }
                        ActionBtn {
                            label: "CLOSE"; tint: Theme.neonRed
                            onActivated: { addingNetwork = false; newSsidField.text = ""; newPassField.text = "" }
                        }
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: root.networks

                        delegate: ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Rectangle {
                                Layout.fillWidth: true
                                height: 40
                                radius: 3
                                color: modelData.active ? Qt.rgba(Theme.neonCyan.r, Theme.neonCyan.g, Theme.neonCyan.b, 0.12) : "transparent"
                                border.width: 1
                                border.color: modelData.active ? Theme.neonCyan : Theme.borderDim

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text { text: "\u2312"; color: Theme.neonBlue; font.pixelSize: 13 }
                                    Text {
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        text: modelData.ssid
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                    }
                                    Text { text: modelData.signal + "%"; color: Theme.neonYellow; font.family: Theme.fontFamily; font.pixelSize: 11 }

                                    ActionBtn {
                                        label: modelData.active ? "ACTIVE" : "CONNECT"
                                        tint: Theme.neonGreen
                                        enabled: !modelData.active
                                        onActivated: {
                                            addingNetwork = false
                                            if (modelData.secured) {
                                                expandedSsid = (expandedSsid === modelData.ssid) ? "" : modelData.ssid
                                                if (expandedSsid === modelData.ssid) Qt.callLater(() => passField.forceActiveFocus())
                                            } else {
                                                connectTo(modelData.ssid, "")
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                visible: expandedSsid === modelData.ssid
                                implicitHeight: visible ? passRow.implicitHeight + 16 : 0
                                radius: 3
                                color: Theme.bgCard
                                border.width: 1
                                border.color: Theme.neonPurple

                                RowLayout {
                                    id: passRow
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    ThemedField {
                                        id: passField
                                        Layout.fillWidth: true
                                        placeholderText: "password"
                                        placeholderTextColor: Theme.textPrimary
                                        echoMode: TextInput.Password
                                        onAccepted: connectTo(modelData.ssid, text)
                                    }
                                    ActionBtn { label: "OK"; tint: Theme.neonGreen; onActivated: connectTo(modelData.ssid, passField.text) }
                                    ActionBtn { label: "CLOSE"; tint: Theme.neonRed; onActivated: { expandedSsid = ""; passField.text = "" } }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
