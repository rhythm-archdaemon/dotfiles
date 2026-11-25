import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config
import qs.services

Rectangle {
    id: root

    Layout.fillWidth: true
    property real containerHeight: 260
    implicitHeight: containerHeight

    radius: Theme.radiusSm
    color: "transparent"
    border.width: 1
    border.color: Theme.neonYellow

    function urgencyColor(urgency) {
        if (urgency === "critical" || urgency === 2) return Theme.neonRed
        if (urgency === "low" || urgency === 0) return Theme.textDim
        return Theme.neonBlue
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
                    onClicked: Notifications.clearAll()
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
                    visible: Notifications.entries.length === 0
                    horizontalAlignment: Text.AlignHCenter
                    text: "no notifications"
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

                Repeater {
                    id: notifRepeater
                    model: Notifications.entries

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
                                        onClicked: Notifications.dismiss(card.modelData.id)
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
                                        id: actionBtn
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
                                            text: actionBtn.modelData.text || ""
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
                                            onClicked: Notifications.invoke(card.modelData.id, actionBtn.modelData.id)
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
