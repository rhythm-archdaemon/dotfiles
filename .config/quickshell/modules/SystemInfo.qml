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
    color: Theme.bgPanel
    clip: true
    border.width: 1
    border.color: Theme.neonGreen

    // Cyberpunk HUD scanline and targeting brackets.
    Rectangle {
        z: 2
        x: 0
        y: -height
        width: root.width
        height: 1
        color: Theme.neonGreen
        opacity: 0.2

        SequentialAnimation on y {
            loops: Animation.Infinite
            NumberAnimation { to: root.height; duration: 4000; easing.type: Easing.Linear }
            PauseAnimation { duration: 800 }
        }
    }
    Rectangle { width: 18; height: 2; x: 8; y: 7; color: Theme.neonGreen }
    Rectangle { width: 2; height: 18; x: 8; y: 7; color: Theme.neonGreen }
    Rectangle { width: 18; height: 2; anchors.right: parent.right; anchors.rightMargin: 8; y: 7; color: Theme.neonCyan }
    Rectangle { width: 2; height: 18; anchors.right: parent.right; anchors.rightMargin: 8; y: 7; color: Theme.neonCyan }

    property int cpuPercent: 0
    property int memPercent: 0
    property int diskPercent: 0
    property string uptimeText: ""
    property var lastCpu: null

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
            Text { text: root.uptimeText; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10 }
            Item { Layout.fillWidth: true }
            Text { text: "RESOURCE MONITOR"; color: Theme.textDim; font.family: Theme.fontFamily; font.pixelSize: 9 }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "CPU"; color: Theme.neonGreen; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 34 }
            Rectangle {
                Layout.fillWidth: true
                height: 8; radius: 1
                color: Qt.rgba(Theme.neonYellow.r, Theme.neonYellow.g, Theme.neonYellow.b, 0.10)
                border.width: 1
                border.color: Qt.rgba(Theme.neonYellow.r, Theme.neonYellow.g, Theme.neonYellow.b, 0.35)
                Rectangle {
                    height: parent.height; radius: 1
                    width: parent.width * Math.min(root.cpuPercent, 100) / 100
                    color: Theme.neonYellow
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }
            Text { text: "[ " + root.cpuPercent + "% ]"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 48; horizontalAlignment: Text.AlignRight }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "MEM"; color: Theme.neonGreen; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 34 }
            Rectangle {
                Layout.fillWidth: true
                height: 8; radius: 1
                color: Qt.rgba(Theme.neonOrange.r, Theme.neonOrange.g, Theme.neonOrange.b, 0.10)
                border.width: 1
                border.color: Qt.rgba(Theme.neonOrange.r, Theme.neonOrange.g, Theme.neonOrange.b, 0.35)
                Rectangle {
                    height: parent.height; radius: 1
                    width: parent.width * Math.min(root.memPercent, 100) / 100
                    color: Theme.neonOrange
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }
            Text { text: "[ " + root.memPercent + "% ]"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 48; horizontalAlignment: Text.AlignRight }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "DISK"; color: Theme.neonGreen; font.family: Theme.fontFamily; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 34 }
            Rectangle {
                Layout.fillWidth: true
                height: 8; radius: 1
                color: Qt.rgba(Theme.neonGreen.r, Theme.neonGreen.g, Theme.neonGreen.b, 0.10)
                border.width: 1
                border.color: Qt.rgba(Theme.neonGreen.r, Theme.neonGreen.g, Theme.neonGreen.b, 0.35)
                Rectangle {
                    height: parent.height; radius: 1
                    width: parent.width * Math.min(root.diskPercent, 100) / 100
                    color: Theme.neonGreen
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }
            Text { text: "[ " + root.diskPercent + "% ]"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 11; Layout.preferredWidth: 48; horizontalAlignment: Text.AlignRight }
        }


    }

    // df has no equivalent under /proc — root filesystem usage % via a
    // one-shot process instead, polled on the same timer as everything else.
    Process {
        id: diskProc
        command: ["df", "--output=pcent", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const match = /(\d+)%/.exec(this.text)
                if (match) root.diskPercent = parseInt(match[1])
            }
        }
    }

    FileView { id: cpuFile; path: "/proc/stat"; onLoaded: root.parseCpu(text()) }
    FileView { id: memFile; path: "/proc/meminfo"; onLoaded: root.parseMem(text()) }
    FileView { id: uptimeFile; path: "/proc/uptime"; onLoaded: root.parseUptime(text()) }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: { cpuFile.reload(); memFile.reload(); uptimeFile.reload(); diskProc.running = true }
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
