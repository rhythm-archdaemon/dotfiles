import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell.Wayland
import qs

// Standalone wifi module. Lists saved NetworkManager profiles first, followed
// by the top 15 visible SSIDs. Saved profiles can reconnect without a password.
Item {
    id: root

    Layout.fillWidth: true
    // Extra height leaves room for saved profiles, visible networks, and
    // inline password forms without making the list feel cramped.
    property real containerHeight: 390
    implicitHeight: containerHeight

    property var networks: []
    property var savedNetworks: []
    property bool showSavedNetworks: false
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
        savedProc.running = true
    }

    Process {
        id: savedProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = []
                for (const line of this.text.trim().split("\n")) {
                    if (!line) continue
                    const separator = line.lastIndexOf(":")
                    if (separator < 0 || line.slice(separator + 1) !== "802-11-wireless") continue
                    const profile = line.slice(0, separator).replace(/\\:/g, ":").replace(/\\\\/g, "\\")
                    if (profile) list.push({ ssid: profile, saved: true, secured: true, active: false })
                }
                root.savedNetworks = list
            }
        }
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

    function reconnectTo(profile) {
        connectProc.command = ["nmcli", "connection", "up", "id", profile]
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

        implicitWidth: lbl.implicitWidth + 14
        implicitHeight: 24
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
        color: Theme.bgPanel
        clip: true
        border.width: 1
        border.color: Theme.neonBlue

        Rectangle {
            z: 2
            x: 0
            y: -height
            width: parent.width
            height: 1
            color: Theme.neonBlue
            opacity: 0.2

            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: root.height; duration: 4200; easing.type: Easing.Linear }
                PauseAnimation { duration: 800 }
            }
        }
        Rectangle { width: 18; height: 2; x: 8; y: 7; color: Theme.neonBlue }
        Rectangle { width: 2; height: 18; x: 8; y: 7; color: Theme.neonBlue }
        Rectangle { width: 18; height: 2; anchors.right: parent.right; anchors.rightMargin: 8; y: 7; color: Theme.neonPurple }
        Rectangle { width: 2; height: 18; anchors.right: parent.right; anchors.rightMargin: 8; y: 7; color: Theme.neonPurple }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text { text: "// NETWORK MATRIX"; color: Theme.neonBlue; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                ActionBtn {
                    label: "+ ADD NODE"; tint: Theme.neonGreen
                    onActivated: {
                        addingNetwork = !addingNetwork
                        expandedSsid = ""
                        if (addingNetwork) Qt.callLater(() => newSsidField.forceActiveFocus())
                    }
                }
                ActionBtn {
                    label: "󰜉  RESCAN"; tint: Theme.neonPurple
                    onActivated: { scanProc.running = true; savedProc.running = true }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                ActionBtn {
                    label: root.showSavedNetworks ? "HIDE SAVED" : "SHOW SAVED (" + root.savedNetworks.length + ")"
                    tint: Theme.neonPurple
                    onActivated: root.showSavedNetworks = !root.showSavedNetworks
                }
                Item { Layout.fillWidth: true }
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
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    // Keep the flickable content tied to the viewport width;
                    // Layout.fillWidth alone does not size Repeater delegates.
                    width: parent.width
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        visible: root.showSavedNetworks && root.savedNetworks.length > 0
                        text: "SAVED PROFILES // PASSWORDLESS RECONNECT"
                        color: Theme.neonPurple
                        font.family: Theme.fontFamily
                        font.bold: true
                        font.pixelSize: 9
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: !root.showSavedNetworks || root.savedNetworks.length === 0
                        text: "VISIBLE NETWORKS // SCAN RESULTS"
                        color: Theme.textDim
                        font.family: Theme.fontFamily
                        font.bold: true
                        font.pixelSize: 9
                    }

                    Repeater {
                        model: (root.showSavedNetworks ? root.savedNetworks : []).concat(root.networks)

                        delegate: ColumnLayout {
                            width: parent.width
                            spacing: 6

                            Rectangle {
                                width: parent.width
                                height: 40
                                radius: 2
                                color: modelData.active ? Qt.rgba(Theme.neonCyan.r, Theme.neonCyan.g, Theme.neonCyan.b, 0.14) : (modelData.saved ? Qt.rgba(Theme.neonPurple.r, Theme.neonPurple.g, Theme.neonPurple.b, 0.10) : Qt.rgba(Theme.borderDim.r, Theme.borderDim.g, Theme.borderDim.b, 0.12))
                                border.width: 1
                                border.color: modelData.active ? Theme.neonCyan : (modelData.saved ? Theme.neonPurple : Theme.borderDim)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text { text: modelData.saved ? "󰖩" : "󰤨"; color: modelData.saved ? Theme.neonPurple : Theme.neonBlue; font.pixelSize: 13 }
                                    Text {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        elide: Text.ElideRight
                                        text: modelData.ssid
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                    }
                                    Text {
                                        Layout.preferredWidth: 48
                                        horizontalAlignment: Text.AlignRight
                                        text: modelData.active ? "ACTIVE" : (modelData.saved ? "SAVED" : modelData.signal + "%")
                                        color: modelData.active ? Theme.neonCyan : (modelData.saved ? Theme.neonPurple : Theme.neonYellow)
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                    }
                                    ActionBtn {
                                        label: modelData.active ? "ACTIVE" : (modelData.saved ? "RECONNECT" : "CONNECT")
                                        tint: modelData.saved ? Theme.neonPurple : Theme.neonGreen
                                        enabled: !modelData.active
                                        onActivated: {
                                            addingNetwork = false
                                            if (modelData.saved) {
                                                reconnectTo(modelData.ssid)
                                            } else if (modelData.secured) {
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
                                width: parent.width
                                visible: !modelData.saved && expandedSsid === modelData.ssid
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
