import QtQuick
import qs.config

// Bordered HUD card: scanline sweep + corner brackets.
// Drop children straight into it; they render above the brackets and below the scanline.
Rectangle {
    id: root

    property color accent: Theme.neonCyan        // scanline + left brackets
    property color accent2: Theme.neonMagenta    // right brackets
    property color borderColor: accent
    property int scanDuration: 4000
    property real scanOpacity: Config.appearance.scanlineOpacity
    property int bracketLength: 18
    property int bracketInset: 8
    property int bracketTop: 7

    radius: Theme.radiusSm
    color: Theme.bgPanel
    clip: true
    border.width: 1
    border.color: root.borderColor

    Rectangle {
        visible: Config.appearance.scanlines
        z: 2
        x: 0
        y: -height
        width: root.width
        height: 1
        color: root.accent
        opacity: root.scanOpacity

        SequentialAnimation on y {
            running: Config.appearance.scanlines
            loops: Animation.Infinite
            NumberAnimation { to: root.height; duration: root.scanDuration; easing.type: Easing.Linear }
            PauseAnimation { duration: 800 }
        }
    }

    Rectangle { visible: Config.appearance.brackets; width: root.bracketLength; height: 2; x: root.bracketInset; y: root.bracketTop; color: root.accent }
    Rectangle { visible: Config.appearance.brackets; width: 2; height: root.bracketLength; x: root.bracketInset; y: root.bracketTop; color: root.accent }
    Rectangle { visible: Config.appearance.brackets; width: root.bracketLength; height: 2; anchors.right: parent.right; anchors.rightMargin: root.bracketInset; y: root.bracketTop; color: root.accent2 }
    Rectangle { visible: Config.appearance.brackets; width: 2; height: root.bracketLength; anchors.right: parent.right; anchors.rightMargin: root.bracketInset; y: root.bracketTop; color: root.accent2 }
}
