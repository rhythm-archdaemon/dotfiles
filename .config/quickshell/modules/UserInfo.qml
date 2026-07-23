import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

// Standalone user-greeting module. Arch banner + time-aware welcome. No
// system stats and no power buttons here anymore — see SystemInfo.qml and
// PowerRow.qml respectively.
Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 28

    radius: Theme.radiusSm
    color: "transparent"
    border.width: 1
    border.color: Theme.neonMagenta

    property string username: Quickshell.env("USER") ?? "stranger"

    readonly property string greeting: {
        const h = new Date().getHours()
        if (h < 5) return "still up,"
        if (h < 12) return "good morning,"
        if (h < 17) return "good afternoon,"
        if (h < 21) return "good evening,"
        return "good night,"
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ── Arch banner ──
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.family: "monospace"
            font.pixelSize: 15
            lineHeight: 1.0
            color: Theme.neonMagenta
            text: `    _    ____   ____ _   _
   / \\  |  _ \\ / ___| | | |
  / _ \\ | |_) | |   | |_| |
 / ___ \\|  _ <| |___|  _  |
/_/   \\_\\_| \\_\\\\____|_| |_|`
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.neonMagenta }

        // ── Time-aware greeting + accent-underlined username ──
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.greeting
                color: Theme.neonCyan
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.username
                color: Theme.neonMagenta
                font.family: Theme.fontFamily
                font.bold: true
                font.pixelSize: 20
            }
        }
    }
}
