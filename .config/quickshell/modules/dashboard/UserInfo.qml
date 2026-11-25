import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components

// User greeting card.
HudPanel {
    id: root

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 28
    borderColor: Theme.neonMagenta
    accent: Theme.neonCyan
    accent2: Theme.neonMagenta
    scanDuration: 4200

    property string username: Quickshell.env("USER") ?? "stranger"
    property date currentTime: new Date()

    readonly property string greeting: {
        const h = root.currentTime.getHours()
        if (h >= 5 && h < 12) return "good morning,"
        if (h >= 12 && h < 17) return "good afternoon,"
        if (h >= 17 && h < 21) return "good evening,"
        return "good night,"
    }

    readonly property var quotes: [
        "Small steps still move the system forward.",
    ]

    readonly property string quoteOfTheDay: {
        const day = Math.floor(root.currentTime.getTime() / 86400000)
        return root.quotes[((day % root.quotes.length) + root.quotes.length) % root.quotes.length]
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "// IDENTITY NODE"
                color: Theme.neonCyan
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 10
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "[ ONLINE ]"
                color: Theme.neonGreen
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 10
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: ">> " + root.username.toUpperCase() + "_"
                color: Theme.neonMagenta
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 22
                font.letterSpacing: 1.2
                elide: Text.ElideRight

                SequentialAnimation on color {
                    loops: Animation.Infinite
                    ColorAnimation { to: Theme.neonCyan; duration: 700 }
                    ColorAnimation { to: Theme.neonPurple; duration: 700 }
                    ColorAnimation { to: Theme.neonBlue; duration: 700 }
                    ColorAnimation { to: Theme.neonMagenta; duration: 700 }
                    ColorAnimation { to: Theme.neonOrange; duration: 700 }
                    ColorAnimation { to: Theme.neonRed; duration: 700 }
                }
            }

            Text {
                text: "USR // 01"
                color: Theme.textDim
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
            }
        }

        // negative margins make the divider reach both inner border edges
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: -16
            Layout.rightMargin: -16
            height: 1
            color: Theme.neonMagenta
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.greeting.toUpperCase()
            color: Theme.neonCyan
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 15
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: quoteContent.implicitHeight + 18
            radius: 3
            color: Qt.rgba(Theme.neonPurple.r, Theme.neonPurple.g, Theme.neonPurple.b, 0.08)
            border.width: 1
            border.color: Qt.rgba(Theme.neonPurple.r, Theme.neonPurple.g, Theme.neonPurple.b, 0.55)

            ColumnLayout {
                id: quoteContent
                anchors.fill: parent
                anchors.margins: 9
                spacing: 5

                Text {
                    Layout.fillWidth: true
                    text: "QUOTE BUFFER // DAILY TRANSMISSION"
                    color: Theme.neonPurple
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: 9
                }

                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: "‘" + root.quoteOfTheDay + "’"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
            }
        }
    }
}
