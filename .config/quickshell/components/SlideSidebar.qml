import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config

// Edge rail that collapses to a 1px sliver and expands on hover.
// Children go into the content column, below the header line.
PanelWindow {
    id: win

    required property var modelData
    screen: modelData

    property string side: "left"            // "left" | "right"
    property color accent: Theme.neonCyan
    property string title: ""
    property int expandedWidth: 400
    property int collapsedWidth: 1
    property bool wantsKeyboard: false      // text inputs inside (wifi password etc.)

    default property alias content: column.data

    readonly property bool onLeft: side === "left"
    readonly property bool isHovered: hover.hovered

    // OnDemand only makes the surface eligible for focus; it never steals it,
    // so it is safe to leave on permanently (toggling live confuses niri).
    WlrLayershell.keyboardFocus: wantsKeyboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        left: win.onLeft
        right: !win.onLeft
    }
    margins { top: Theme.barHeight }
    implicitWidth: expandedWidth
    implicitHeight: screen.height - Theme.barHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: panel }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: win.onLeft ? parent.left : undefined
        anchors.right: win.onLeft ? undefined : parent.right
        width: win.isHovered ? win.expandedWidth : win.collapsedWidth
        color: Theme.bgPanel
        clip: true
        radius: Theme.radiusMd
        border.width: win.onLeft ? 1 : 2
        border.color: win.accent

        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        // inner edge accent line
        Rectangle {
            z: 3
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: win.onLeft ? parent.right : undefined
            anchors.left: win.onLeft ? undefined : parent.left
            width: 2
            color: win.accent
            opacity: 0.8
        }

        // scanline
        Rectangle {
            visible: Config.appearance.scanlines
            z: 2
            x: 0
            y: -height
            width: parent.width
            height: 1
            color: win.accent
            opacity: 0.18
            SequentialAnimation on y {
                running: Config.appearance.scanlines
                loops: Animation.Infinite
                NumberAnimation { to: panel.height; duration: 4800; easing.type: Easing.Linear }
                PauseAnimation { duration: 900 }
            }
        }

        // top corner bracket (outer corner)
        Rectangle {
            visible: Config.appearance.brackets
            z: 3; width: 22; height: 2; y: 8
            color: win.accent
            x: win.onLeft ? 8 : parent.width - width - 8
        }
        Rectangle {
            visible: Config.appearance.brackets
            z: 3; width: 2; height: 22; y: 8
            color: win.accent
            x: win.onLeft ? 8 : parent.width - width - 8
        }

        // HoverHandler passively samples the pointer without filtering child events.
        HoverHandler { id: hover }

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 16
            anchors.topMargin: 18
            spacing: 16
            opacity: win.isHovered ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Text {
                Layout.fillWidth: true
                text: win.title
                color: win.accent
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 10
            }
        }
    }
}
