import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.services

HudPanel {
    id: root

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 28
    borderColor: Theme.neonGreen
    accent: Theme.neonGreen
    accent2: Theme.neonCyan
    scanDuration: 4000

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "// SYSTEM CORE"; color: Theme.neonGreen; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 11 }
            Item { Layout.fillWidth: true }
            Text { text: "[ NOMINAL ]"; color: Theme.neonCyan; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 10 }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "UPTIME //"; color: Theme.textDim; font.family: Theme.fontFamily; font.pixelSize: 10 }
            Text { text: SystemStats.uptimeText; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10 }
            Item { Layout.fillWidth: true }
            Text { text: "RESOURCE MONITOR"; color: Theme.textDim; font.family: Theme.fontFamily; font.pixelSize: 9 }
        }

        StatBar { label: "CPU";  percent: SystemStats.cpuPercent;  tint: Theme.neonYellow }
        StatBar { label: "MEM";  percent: SystemStats.memPercent;  tint: Theme.neonOrange }
        StatBar { label: "DISK"; percent: SystemStats.diskPercent; tint: Theme.neonGreen }
    }
}
