import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import qs

Rectangle {
    id: root

    Layout.fillWidth: true
    property real containerHeight: 260
    implicitHeight: containerHeight

    radius: Theme.radiusSm
    color: "transparent"
    border.width: 1
    border.color: Theme.neonYellow

    property var notifications: []

    Process {
        id: activeProc
        command: ["makoctl", "list", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.updateNotifications(this.text, false)
        }
    }

    Process {
        id: historyProc
        command: ["makoctl", "history", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.updateNotifications(this.text, true)
        }
    }

    Process { id: commandProc }

    function updateNotifications(json, fromHistory) {
        let entries
        try {
            entries = JSON.parse(json)
        } catch (error) {
            return
        }
        if (!Array.isArray(entries)) return

        const other = root.notifications.filter(n => n.fromHistory !== fromHistory)
        const parsed = entries.map(n => ({
            id: n.id,
            appName: n["app-name"] || n.appName || "notification",
            summary: n.summary || "",
            body: n.body || "",
            urgency: n.urgency || "normal",
            actions: (n.actions || []).map(a => ({
                text: a.name || a.text || a.id || "",
                id: a.id || a.identifier || ""
            })),
            fromHistory: fromHistory
        }))
        root.notifications = other.concat(parsed)
    }

    function urgencyColor(urgency) {
        if (urgency === "critical" || urgency === 2) return Theme.neonRed
        if (urgency === "low" || urgency === 0) return Theme.textDim
        return Theme.neonBlue
    }

    function refresh() {
        if (!activeProc.running) activeProc.running = true
        if (!historyProc.running) historyProc.running = true
    }

    function dismissNotification(id) {
        commandProc.command = ["makoctl", "dismiss", "-n", String(id)]
        commandProc.running = true
        Qt.callLater(refresh)
    }

    function invokeNotificationAction(id, action) {
        commandProc.command = ["makoctl", "invoke", "-n", String(id), action]
        commandProc.running = true
    }

    Component.onCompleted: refresh()

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text { text: "NOTIFICATIONS"; color: Theme.neonYellow; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 12 }
            Item { Layout.fillWidth: true }
            Text {
                text: notifRepeater.count
                color: Theme.neonMagenta
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 12
            }
            Text {
                text: "CLEAR"
                color: Theme.neonRed
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 11
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        commandProc.command = ["makoctl", "dismiss", "--all"]
                        commandProc.running = true
                        root.notifications = []
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

                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 12
                    visible: root.notifications.length === 0
                    horizontalAlignment: Text.AlignHCenter
                    text: "no notifications"
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

                Repeater {
                    id: notifRepeater
                    model: root.notifications

                    delegate: Rectangle {
                        id: card
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: cardContent.implicitHeight + 20
                        radius: Theme.radiusSm
                        color: Theme.bgCard
                        border.width: 1
                        border.color: root.urgencyColor(modelData.urgency)

                        ColumnLayout {
                            id: cardContent
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: root.urgencyColor(card.modelData.urgency)
                                }
                                Text {
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    text: card.modelData.appName || "notification"
                                    color: Theme.textDim
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: "\u2715"
                                    color: Theme.textDim
                                    font.pixelSize: 12
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -4
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.dismissNotification(card.modelData.id)
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                                text: card.modelData.summary || ""
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.bold: true
                                font.pixelSize: 13
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: !!card.modelData.body
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                text: card.modelData.body || ""
                                color: Theme.textDim
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                visible: (card.modelData.actions || []).length > 0

                                Repeater {
                                    model: card.modelData.actions || []
                                    delegate: Rectangle {
                                        required property var modelData
                                        implicitWidth: actionLbl.implicitWidth + 16
                                        implicitHeight: 24
                                        radius: Theme.radiusSm
                                        color: actionMouse.containsMouse ? Theme.neonGreen : "transparent"
                                        border.width: 1
                                        border.color: Theme.neonGreen
                                        Behavior on color { ColorAnimation { duration: 120 } }

                                        Text {
                                            id: actionLbl
                                            anchors.centerIn: parent
                                            text: parent.modelData.text || ""
                                            color: actionMouse.containsMouse ? Theme.bgPanel : Theme.neonGreen
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                        MouseArea {
                                            id: actionMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.invokeNotificationAction(card.modelData.id, parent.modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
