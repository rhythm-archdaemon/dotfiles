pragma Singleton
import QtQuick

// Central palette. Every widget pulls its accent from here so you can
// re-theme the whole bar by editing this one file.
QtObject {
    // surfaces
    readonly property color bgVoid:   "#06070d"
    readonly property color bgPanel:  "#0b0e18"
    readonly property color bgCard:   "#10141f"
    readonly property color borderDim:"#1c2435"

    // one neon accent per component, as requested
    readonly property color neonCyan:    "#00fff2" // workspaces
    readonly property color neonMagenta: "#ff2bd6" // media player
    readonly property color neonPurple:  "#b026ff" // cava visualizer
    readonly property color neonYellow:  "#ffe600" // brightness
    readonly property color neonBlue:    "#00b3ff" // wifi
    readonly property color neonGreen:   "#39ff8f" // battery: charging/full
    readonly property color neonOrange:  "#ff8a00" // battery: mid / reboot
    readonly property color neonRed:     "#ff2050" // battery: low / power off

    readonly property color textPrimary: "#eaf6ff"
    readonly property color textDim:     "#5f7390"

    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 12
    property int barHeight: 40
    property int radiusSm: 10
    property int radiusMd: 0
}
