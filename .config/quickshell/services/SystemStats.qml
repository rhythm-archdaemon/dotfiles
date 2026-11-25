pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// CPU / memory / disk / uptime from /proc and df.
Singleton {
    id: root

    property int cpuPercent: 0
    property int memPercent: 0
    property int diskPercent: 0
    property string uptimeText: ""
    property var lastCpu: null

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
        interval: Config.services.statsPollMs
        running: true
        repeat: true
        onTriggered: {
            cpuFile.reload()
            memFile.reload()
            uptimeFile.reload()
            diskProc.running = true
        }
    }
}
