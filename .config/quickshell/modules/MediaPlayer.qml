import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs

// Controls whichever MPRIS player is first in the list. If you run
// multiple players at once and want to pick a specific one, swap
// Mpris.players.values[0] for a search over .values by identity/desktopEntry.
RowLayout {
    id: root
    spacing: 10

    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool playing: !!root.player && root.player.playbackState === MprisPlaybackState.Playing
    readonly property string trackLabel: root.player
        ? ((root.player.trackArtist ? root.player.trackArtist + " – " : "") + (root.player.trackTitle || "Unknown Track"))
        : "No media playing"

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: "\u23EE" // ⏮
        color: root.player && root.player.canGoPrevious ? Theme.neonMagenta : Theme.textDim
        font.pixelSize: 15

        MouseArea {
            anchors.fill: parent
            anchors.margins: -5
            cursorShape: Qt.PointingHandCursor
            enabled: !!root.player && root.player.canGoPrevious
            onClicked: root.player.previous()
        }
    }

    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        width: 26; height: 26; radius: 13
        color: "transparent"
        border.width: 2
        border.color: Theme.neonMagenta

        Text {
            anchors.centerIn: parent
            text: root.playing ? "\u23F8" : "\u25B6" // ⏸ / ▶
            color: Theme.neonMagenta
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: !!root.player
            onClicked: root.playing ? root.player.pause() : root.player.play()
        }
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: "\u23ED" // ⏭
        color: root.player && root.player.canGoNext ? Theme.neonMagenta : Theme.textDim
        font.pixelSize: 15

        MouseArea {
            anchors.fill: parent
            anchors.margins: -5
            cursorShape: Qt.PointingHandCursor
            enabled: !!root.player && root.player.canGoNext
            onClicked: root.player.next()
        }
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        Layout.maximumWidth: 220
        elide: Text.ElideRight
        text: root.trackLabel
        color: Theme.neonMagenta
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
