pragma Singleton
import QtQuick

// Central palette. Every widget pulls its accent from here so you can
// re-theme the whole bar by editing this one file.
QtObject {
    // surfaces (Tokyo Night Deep Blues/Grays)
    readonly property color bgVoid:   "#1a1b26" // Main background (Storm/Night base)
    readonly property color bgPanel:  "#16161e" // Slightly darker for contrast panels
    readonly property color bgCard:   "#24283b" // Lighter surface for cards/elements
    readonly property color borderDim:"#383e5a" // Subtle border/selection line

    // Tokyo Night accents (Vibrant yet balanced)
    readonly property color neonCyan:    "#7dcfff" // workspaces (Cyan/Sky Blue)
    readonly property color neonMagenta: "#bb9af7" // media player (Purple/Magenta)
    readonly property color neonPurple:  "#9d7cd8" // cava visualizer (Deep Purple)
    readonly property color neonYellow:  "#e0af68" // brightness (Warm Yellow)
    readonly property color neonBlue:    "#7aa2f7" // wifi (Classic Tokyo Blue)
    readonly property color neonGreen:   "#9ece6a" // battery: charging/full (Fresh Green)
    readonly property color neonOrange:  "#ff9e64" // battery: mid / reboot (Orange)
    readonly property color neonRed:     "#f7768e" // battery: low / power off (Red/Coral)

    // typography
    readonly property color textPrimary: "#c0caf5" // Soft, readable white-blue
    readonly property color textDim:     "#565f89" // Muted gray-blue for secondary text    property string fontFamily: "JetBrainsMono Nerd Font"
    
    property int fontSize: 13
    property int barHeight: 30
    property int radiusSm: 10
    property int radiusMd: 0
}
