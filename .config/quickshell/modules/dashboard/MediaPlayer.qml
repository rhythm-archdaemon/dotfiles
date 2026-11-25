import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services

HudPanel {
    id: root

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 28
    borderColor: Theme.neonRed
    accent: Theme.neonRed
    accent2: Theme.neonMagenta
    scanDuration: 3800

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "// AUDIO DECK"
                color: Theme.neonRed
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 10
            }
            Item { Layout.fillWidth: true }
            Text {
                text: Media.playing ? "[ STREAMING ]" : "[ STANDBY ]"
                color: Media.playing ? Theme.neonGreen : Theme.textDim
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 10
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: trackInfo.implicitHeight + 18
            radius: 3
            color: Qt.rgba(Theme.neonRed.r, Theme.neonRed.g, Theme.neonRed.b, 0.08)
            border.width: 1
            border.color: Qt.rgba(Theme.neonRed.r, Theme.neonRed.g, Theme.neonRed.b, 0.55)

            ColumnLayout {
                id: trackInfo
                anchors.fill: parent
                anchors.margins: 9
                spacing: 5

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: Media.title
                    color: Theme.neonMagenta
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: 15
                }
                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    visible: Media.artist !== ""
                    text: "ARTIST // " + Media.artist
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            IconButton {
                glyph: "\u23EE"
                tint: Theme.neonRed
                enabled: Media.canPrevious
                onActivated: Media.previous()
            }
            IconButton {
                glyph: Media.playing ? "\u23F8" : "\u25B6"
                tint: Theme.neonGreen
                enabled: Media.hasPlayer
                onActivated: Media.togglePlaying()
            }
            IconButton {
                glyph: "\u23ED"
                tint: Theme.neonRed
                enabled: Media.canNext
                onActivated: Media.next()
            }
        }
    }
}
