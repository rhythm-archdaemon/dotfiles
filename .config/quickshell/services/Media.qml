pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.config

// Picks the "music" MPRIS player. MPRIS also exposes browsers and video
// players, and ObjectModel order says nothing about which one is playing.
Singleton {
    id: root

    function isMusicPlayer(candidate) {
        if (!candidate || !candidate.trackTitle || !candidate.trackArtist) return false

        const identity = ((candidate.identity || "") + " " + (candidate.desktopEntry || "")).toLowerCase()
        for (const name of Config.services.ignoredPlayers) {
            if (identity.includes(name)) return false
        }
        return true
    }

    readonly property var player: {
        const players = Mpris.players.values
        // Prefer a qualifying player that is actually playing.
        for (const candidate of players) {
            if (candidate.playbackState === MprisPlaybackState.Playing && isMusicPlayer(candidate))
                return candidate
        }
        // Keep a paused music player so its play button can resume it.
        for (const candidate of players) {
            if (isMusicPlayer(candidate)) return candidate
        }
        return null
    }

    readonly property bool hasPlayer: !!player
    readonly property bool playing: !!player && player.playbackState === MprisPlaybackState.Playing
    readonly property bool canPrevious: !!player && player.canGoPrevious
    readonly property bool canNext: !!player && player.canGoNext
    readonly property string title: player ? (player.trackTitle || "UNKNOWN TRACK") : "NO SIGNAL"
    readonly property string artist: player ? (player.trackArtist || "") : ""

    function togglePlaying() {
        if (!player) return
        if (playing) player.pause()
        else player.play()
    }
    function previous() { if (player) player.previous() }
    function next() { if (player) player.next() }
}
