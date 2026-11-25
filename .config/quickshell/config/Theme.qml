pragma Singleton
import QtQuick

// Design tokens. Values come from shell.json (via Config) so the whole
// shell can be re-themed without touching QML.
QtObject {
    // surfaces
    readonly property color bgVoid:     Config.palette.bgVoid
    readonly property color bgPanel:    Config.palette.bgPanel
    readonly property color bgCard:     Config.palette.bgCard
    readonly property color borderDim:  Config.palette.borderDim

    // accents
    readonly property color neonCyan:    Config.palette.neonCyan
    readonly property color neonMagenta: Config.palette.neonMagenta
    readonly property color neonPurple:  Config.palette.neonPurple
    readonly property color neonYellow:  Config.palette.neonYellow
    readonly property color neonBlue:    Config.palette.neonBlue
    readonly property color neonGreen:   Config.palette.neonGreen
    readonly property color neonOrange:  Config.palette.neonOrange
    readonly property color neonRed:     Config.palette.neonRed

    // typography
    readonly property color textPrimary: Config.palette.textPrimary
    readonly property color textDim:     Config.palette.textDim
    readonly property string fontFamily: Config.appearance.fontFamily
    readonly property int fontSize:      Config.appearance.fontSize

    // geometry
    readonly property int barHeight: Config.bar.height
    readonly property int radiusSm:  Config.appearance.radiusSm
    readonly property int radiusMd:  Config.appearance.radiusMd
}
