import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config
import qs.components
import qs.services

// Bluetooth picker: power, scan, pair / connect / disconnect / forget.
// Tip for headphones: put them in pairing mode, hit SCAN, then PAIR.
HudPanel {
    id: root

    Layout.fillWidth: true
    property real containerHeight: 280
    implicitHeight: containerHeight

    radius: 5
    borderColor: Theme.neonCyan
    accent: Theme.neonCyan
    accent2: Theme.neonPurple
    scanDuration: 4400

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text { text: "// BLUETOOTH LINK"; color: Theme.neonCyan; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 11 }
            Item { Layout.fillWidth: true }
            ActionBtn {
                label: BluetoothStatus.powered ? "POWER: ON" : "POWER: OFF"
                tint: BluetoothStatus.powered ? Theme.neonGreen : Theme.neonRed
                enabled: BluetoothStatus.available
                onActivated: BluetoothStatus.setPowered(!BluetoothStatus.powered)
            }
            ActionBtn {
                label: BluetoothStatus.scanning ? "STOP" : "󰂰  SCAN"
                tint: Theme.neonPurple
                enabled: BluetoothStatus.powered
                onActivated: BluetoothStatus.toggleScan()
            }
        }

        Text {
            Layout.fillWidth: true
            text: !BluetoothStatus.available ? "NO ADAPTER // is bluetooth.service running?"
                : !BluetoothStatus.powered ? "RADIO OFFLINE // power on to continue"
                : BluetoothStatus.scanning ? "SCANNING // put headphones in pairing mode"
                : "DEVICES // paired first, then nearby"
            color: BluetoothStatus.scanning ? Theme.neonYellow : Theme.textDim
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 9
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: parent.width
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 12
                    visible: BluetoothStatus.powered && BluetoothStatus.devices.length === 0
                    horizontalAlignment: Text.AlignHCenter
                    text: "no devices — hit SCAN"
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

                Repeater {
                    model: BluetoothStatus.powered ? BluetoothStatus.devices : []

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        readonly property bool busy: BluetoothStatus.isBusy(modelData)

                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 2
                        color: modelData.connected
                            ? Qt.rgba(Theme.neonCyan.r, Theme.neonCyan.g, Theme.neonCyan.b, 0.14)
                            : (modelData.paired
                                ? Qt.rgba(Theme.neonPurple.r, Theme.neonPurple.g, Theme.neonPurple.b, 0.10)
                                : Qt.rgba(Theme.borderDim.r, Theme.borderDim.g, Theme.borderDim.b, 0.12))
                        border.width: 1
                        border.color: modelData.connected ? Theme.neonCyan : (modelData.paired ? Theme.neonPurple : Theme.borderDim)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                text: "󰋋"
                                color: row.modelData.connected ? Theme.neonCyan : Theme.neonPurple
                                font.pixelSize: 15
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    text: row.modelData.name || row.modelData.address
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                }
                                Text {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 9
                                    font.bold: true
                                    text: {
                                        if (row.modelData.pairing) return "PAIRING…"
                                        if (row.busy) return "WORKING…"
                                        if (row.modelData.connected)
                                            return "CONNECTED" + (row.modelData.batteryAvailable ? "  //  BAT " + Math.round(row.modelData.battery * 100) + "%" : "")
                                        if (row.modelData.paired) return "PAIRED"
                                        return "AVAILABLE"
                                    }
                                    color: row.modelData.connected ? Theme.neonCyan
                                        : row.modelData.paired ? Theme.neonPurple
                                        : Theme.neonYellow
                                }
                            }

                            ActionBtn {
                                label: row.modelData.connected ? "DISCONNECT" : (row.modelData.paired ? "CONNECT" : "PAIR")
                                tint: row.modelData.connected ? Theme.neonRed : Theme.neonGreen
                                enabled: !row.busy
                                onActivated: BluetoothStatus.primaryAction(row.modelData)
                            }
                            ActionBtn {
                                visible: row.modelData.paired
                                label: "✕"
                                tint: Theme.neonRed
                                enabled: !row.busy
                                onActivated: BluetoothStatus.forget(row.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
