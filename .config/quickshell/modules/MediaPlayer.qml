import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs

Rectangle {
    id: root

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 28

    radius: 5
    color: "transparent"
    border.width: 1
    border.color: Theme.neonRed

    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool playing: !!player && player.playbackState === MprisPlaybackState.Playing

    component ControlBtn: Rectangle {
        id: btn
        property string glyph: ""
        property color tint: Theme.neonMagenta
        property bool enabled: true
        signal activated()

        width: 34; height: 34
        radius: Theme.radiusSm
        opacity: enabled ? 1 : 0.35
        color: mouse.containsMouse && enabled ? tint : "transparent"
        border.width: 1
        border.color: tint
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: btn.glyph
            color: mouse.containsMouse && btn.enabled ? Theme.bgPanel : btn.tint
            font.pixelSize: 15
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

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Text {
            text: "NOW PLAYING"
            color: Theme.neonRed
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 12
        }

        // --- Track info ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: root.player ? (root.player.trackTitle || "Unknown Track") : "Nothing playing"
                color: Theme.neonMagenta
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 14
            }
            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                visible: !!root.player && !!root.player.trackArtist
                text: root.player ? (root.player.trackArtist || "") : ""
                color: Theme.textDim
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
        }

        // --- Controls ---
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 18

            ControlBtn {
                glyph: "\u23EE"
                tint: Theme.neonRed
                enabled: !!root.player && root.player.canGoPrevious
                onActivated: root.player.previous()
            }
            ControlBtn {
                glyph: root.playing ? "\u23F8" : "\u25B6"
                tint: Theme.neonGreen
                enabled: !!root.player
                onActivated: root.playing ? root.player.pause() : root.player.play()
            }
            ControlBtn {
                glyph: "\u23ED"
                tint: Theme.neonRed
                enabled: !!root.player && root.player.canGoNext
                onActivated: root.player.next()
            }
        }
    }
}
