import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config
import qs.components
import qs.services

// Wifi picker. Saved NetworkManager profiles reconnect without a password;
// visible networks (top 15 by signal) open an inline password field.
HudPanel {
    id: root

    Layout.fillWidth: true
    property real containerHeight: 390
    implicitHeight: containerHeight

    radius: 5
    borderColor: Theme.neonBlue
    accent: Theme.neonBlue
    accent2: Theme.neonPurple
    scanDuration: 4200

    property bool showSavedNetworks: false
    property string expandedSsid: ""
    property bool addingNetwork: false

    function connectTo(ssid, password) {
        Network.connectTo(ssid, password)
        expandedSsid = ""
        addingNetwork = false
    }

    function reconnectTo(profile) {
        Network.reconnectTo(profile)
        expandedSsid = ""
        addingNetwork = false
    }

    Component.onCompleted: Network.refreshAll()

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
                    root.addingNetwork = !root.addingNetwork
                    root.expandedSsid = ""
                    if (root.addingNetwork) Qt.callLater(() => newSsidField.forceActiveFocus())
                }
            }
            ActionBtn {
                label: "󰜉  RESCAN"; tint: Theme.neonPurple
                onActivated: { Network.scan(); Network.loadSaved() }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            ActionBtn {
                label: root.showSavedNetworks ? "HIDE SAVED" : "SHOW SAVED (" + Network.savedNetworks.length + ")"
                tint: Theme.neonPurple
                onActivated: root.showSavedNetworks = !root.showSavedNetworks
            }
            Item { Layout.fillWidth: true }
        }

        Rectangle {
            Layout.fillWidth: true
            visible: root.addingNetwork
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

                ThemedField { id: newSsidField; Layout.fillWidth: true; placeholderText: "network name (SSID)" }
                ThemedField { id: newPassField; Layout.fillWidth: true; placeholderText: "password"; echoMode: TextInput.Password }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Item { Layout.fillWidth: true }
                    ActionBtn {
                        label: "CONNECT"; tint: Theme.neonGreen
                        onActivated: { root.connectTo(newSsidField.text, newPassField.text); newSsidField.text = ""; newPassField.text = "" }
                    }
                    ActionBtn {
                        label: "CLOSE"; tint: Theme.neonRed
                        onActivated: { root.addingNetwork = false; newSsidField.text = ""; newPassField.text = "" }
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
                // Keep flickable content tied to the viewport width;
                // Layout.fillWidth alone does not size Repeater delegates.
                width: parent.width
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    visible: root.showSavedNetworks && Network.savedNetworks.length > 0
                    text: "SAVED PROFILES // PASSWORDLESS RECONNECT"
                    color: Theme.neonPurple
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: 9
                }

                Text {
                    Layout.fillWidth: true
                    visible: !root.showSavedNetworks || Network.savedNetworks.length === 0
                    text: "VISIBLE NETWORKS // SCAN RESULTS"
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: 9
                }

                Repeater {
                    model: (root.showSavedNetworks ? Network.savedNetworks : []).concat(Network.networks)

                    delegate: ColumnLayout {
                        width: parent.width
                        spacing: 6

                        Rectangle {
                            width: parent.width
                            height: 40
                            radius: 2
                            color: modelData.active
                                ? Qt.rgba(Theme.neonCyan.r, Theme.neonCyan.g, Theme.neonCyan.b, 0.14)
                                : (modelData.saved
                                    ? Qt.rgba(Theme.neonPurple.r, Theme.neonPurple.g, Theme.neonPurple.b, 0.10)
                                    : Qt.rgba(Theme.borderDim.r, Theme.borderDim.g, Theme.borderDim.b, 0.12))
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
                                        root.addingNetwork = false
                                        if (modelData.saved) {
                                            root.reconnectTo(modelData.ssid)
                                        } else if (modelData.secured) {
                                            root.expandedSsid = (root.expandedSsid === modelData.ssid) ? "" : modelData.ssid
                                            if (root.expandedSsid === modelData.ssid) Qt.callLater(() => passField.forceActiveFocus())
                                        } else {
                                            root.connectTo(modelData.ssid, "")
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            visible: !modelData.saved && root.expandedSsid === modelData.ssid
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
                                    echoMode: TextInput.Password
                                    onAccepted: root.connectTo(modelData.ssid, text)
                                }
                                ActionBtn { label: "OK"; tint: Theme.neonGreen; onActivated: root.connectTo(modelData.ssid, passField.text) }
                                ActionBtn { label: "CLOSE"; tint: Theme.neonRed; onActivated: { root.expandedSsid = ""; passField.text = "" } }
                            }
                        }
                    }
                }
            }
        }
    }
}
