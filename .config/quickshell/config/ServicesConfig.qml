import Quickshell.Io

JsonObject {
    // polling intervals (ms)
    property int statsPollMs: 2000
    property int networkPollMs: 5000
    property int brightnessPollMs: 1000
    property int notificationPollMs: 2000

    // MPRIS players that should never be treated as "the music player"
    property var ignoredPlayers: [
        "firefox", "chromium", "chrome", "brave", "vivaldi", "opera", "browser",
        "youtube", "mpv", "vlc", "celluloid", "totem", "haruna", "video"
    ]

    // session commands (argv arrays)
    property var lockCommand: ["gtklock"]
    property var rebootCommand: ["systemctl", "reboot"]
    property var poweroffCommand: ["systemctl", "poweroff"]
}
