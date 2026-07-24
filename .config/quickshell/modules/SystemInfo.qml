import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs

// Standalone system-stats module — extracted out of the old UserInfo.qml.
// Same /proc-based polling, now themed and in its own bordered container.
Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 28

    radius: Theme.radiusSm
    color: "transparent"
    border.width: 1
    border.color: Theme.neonGreen

    property int cpuPercent: 0
    property int memPercent: 0
    property string uptimeText: ""
    property var lastCpu: null

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        Text {
            text: "SYSTEM"
            color: Theme.neonGreen
            font.family: Theme.fontFamily
            font.bold: true
            font.pixelSize: 12
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "cpu"; color: Theme.neonYellow; font.family: Theme.fontFamily; font.pixelSize: 12; Layout.preferredWidth: 32 }
            Rectangle {
                Layout.fillWidth: true
                height: 6; radius: 3
                color: Theme.bgCard
                Rectangle {
                    height: parent.height; radius: 3
                    width: parent.width * Math.min(root.cpuPercent, 100) / 100
                    color: Theme.neonYellow
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }
            Text { text: root.cpuPercent + "%"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; Layout.preferredWidth: 38; horizontalAlignment: Text.AlignRight }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "mem"; color: Theme.neonYellow; font.family: Theme.fontFamily; font.pixelSize: 12; Layout.preferredWidth: 32 }
            Rectangle {
                Layout.fillWidth: true
                height: 6; radius: 3
                color: Theme.bgCard
                Rectangle {
                    height: parent.height; radius: 3
                    width: parent.width * Math.min(root.memPercent, 100) / 100
                    color: Theme.neonOrange
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }
            Text { text: root.memPercent + "%"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 12; Layout.preferredWidth: 38; horizontalAlignment: Text.AlignRight }
        }

        Text {
            text: "up " + root.uptimeText
            color: Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }
    }

    FileView { id: cpuFile; path: "/proc/stat"; onLoaded: root.parseCpu(text()) }
    FileView { id: memFile; path: "/proc/meminfo"; onLoaded: root.parseMem(text()) }
    FileView { id: uptimeFile; path: "/proc/uptime"; onLoaded: root.parseUptime(text()) }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: { cpuFile.reload(); memFile.reload(); uptimeFile.reload() }
    }

    function parseCpu(content) {
        const parts = content.split("\n")[0].trim().split(/\s+/)
        let total = 0
        for (let i = 1; i < parts.length; i++) total += parseInt(parts[i])
        const idle = parseInt(parts[4]) + parseInt(parts[5])
        if (lastCpu) {
            const dTotal = total - lastCpu.total
            const dIdle = idle - lastCpu.idle
            cpuPercent = dTotal > 0 ? Math.round(100 * (dTotal - dIdle) / dTotal) : 0
        }
        lastCpu = { total: total, idle: idle }
    }

    function parseMem(content) {
        const total = /MemTotal:\s+(\d+)/.exec(content)
        const avail = /MemAvailable:\s+(\d+)/.exec(content)
        if (total && avail)
            memPercent = Math.round(100 * (1 - parseInt(avail[1]) / parseInt(total[1])))
    }

    function parseUptime(content) {
        const secs = parseFloat(content.split(" ")[0])
        const d = Math.floor(secs / 86400)
        const h = Math.floor(secs % 86400 / 3600)
        const m = Math.floor(secs % 3600 / 60)
        uptimeText = (d > 0 ? d + "d " : "") + h + "h " + m + "m"
    }
}
