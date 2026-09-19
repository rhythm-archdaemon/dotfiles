import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs

Rectangle {
    id: root

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 28

    radius: 5
    color: Theme.bgPanel
    clip: true
    border.width: 1
    border.color: Theme.neonRed

    // HUD scanline and corner brackets give the player a terminal-console look.
    Rectangle {
        z: 2
        x: 0
        y: -height
        width: root.width
        height: 1
        color: Theme.neonRed
        opacity: 0.2

        SequentialAnimation on y {
            loops: Animation.Infinite
            NumberAnimation { to: root.height; duration: 3800; easing.type: Easing.Linear }
            PauseAnimation { duration: 700 }
        }
    }
    Rectangle { width: 18; height: 2; x: 8; y: 7; color: Theme.neonRed }
    Rectangle { width: 2; height: 18; x: 8; y: 7; color: Theme.neonRed }
    Rectangle { width: 18; height: 2; anchors.right: parent.right; anchors.rightMargin: 8; y: 7; color: Theme.neonMagenta }
    Rectangle { width: 2; height: 18; anchors.right: parent.right; anchors.rightMargin: 8; y: 7; color: Theme.neonMagenta }

    // MPRIS also exposes browsers and video players. Do not blindly use the
    // first player: ObjectModel order is not a reliable indication of the
    // player currently playing music.
    function isMusicPlayer(candidate) {
        if (!candidate || !candidate.trackTitle || !candidate.trackArtist) return false

        const identity = ((candidate.identity || "") + " " + (candidate.desktopEntry || "")).toLowerCase()
        const nonMusicPlayers = [
            "firefox", "chromium", "chrome", "brave", "vivaldi", "opera", "browser",
            "youtube", "mpv", "vlc", "celluloid", "totem", "haruna", "video"
        ]
        return !nonMusicPlayers.some(name => identity.includes(name))
    }

    readonly property var player: {
        const players = Mpris.players.values
        // Prefer a qualifying player that is actually playing.
        for (const candidate of players) {
            if (candidate.playbackState === MprisPlaybackState.Playing && isMusicPlayer(candidate))
                return candidate
        }
        // Keep a paused music player available so its play button can resume it.
        for (const candidate of players) {
            if (isMusicPlayer(candidate)) return candidate
        }
        return null
    }
    readonly property bool playing: !!root.player && root.player.playbackState === MprisPlaybackState.Playing

    component ControlBtn: Rectangle {
        id: btn
        property string glyph: ""
        property color tint: Theme.neonMagenta
        property bool enabled: true
        signal activated()

        width: 38; height: 34
        radius: 2
        opacity: enabled ? 1 : 0.35
        color: mouse.containsMouse && enabled ? tint : Qt.rgba(tint.r, tint.g, tint.b, 0.06)
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
        spacing: 10

        // ── Cyberpunk player header ──
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
                text: root.playing ? "[ STREAMING ]" : "[ STANDBY ]"
                color: root.playing ? Theme.neonGreen : Theme.textDim
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
                    text: root.player ? (root.player.trackTitle || "UNKNOWN TRACK") : "NO SIGNAL"
                    color: Theme.neonMagenta
                    font.family: Theme.fontFamily
                    font.bold: true
                    font.pixelSize: 15
                }
                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    visible: !!root.player && !!root.player.trackArtist
                    text: root.player ? ("ARTIST // " + (root.player.trackArtist || "")) : ""
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }
        }

        // ── Transport controls ──
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

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
