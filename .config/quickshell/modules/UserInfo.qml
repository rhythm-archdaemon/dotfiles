// ~/.config/quickshell/modules/UserInfo.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ColumnLayout {
    id: root
    spacing: 14

    // ── palette: swap these for your Theme.* tokens if you have equivalents ──
    readonly property color cText:   "#cdd6f4"
    readonly property color cDim:    "#7f849c"
    readonly property color cAccent: "#89b4fa"
    readonly property color cCard:   "#313244"

    property int cpuPercent: 0
    property int memPercent: 0
    property string uptimeText: ""
    property var lastCpu: null

    // ──────────────────────────────────────────────
    //  A - Arch   (figlet banner — backslashes doubled!)
    // ──────────────────────────────────────────────
    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        font.family: "monospace"   // mandatory or the art collapses
        font.pixelSize: 13
        lineHeight: 1.0
        color: root.cAccent
        text: `    _    ____   ____ _   _
   / \\  |  _ \\ / ___| | | |
  / _ \\ | |_) | |   | |_| |
 / ___ \\|  _ <| |___|  _  |
/_/   \\_\\_| \\_\\\\____|_| |_|`
    }

    // ── divider (your "-------------") ──
    Rectangle { Layout.fillWidth: true; height: 1; color: root.cCard }

    // ── welcome - username ──
    Text {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: "welcome - " + (Quickshell.env("USER") ?? "stranger")
        color: root.cText
        font.pixelSize: 18
        font.bold: true
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: root.cCard }

    // ──────────────────────────────────────────────
    //  ~60% section: live system stats + power buttons
    // ──────────────────────────────────────────────
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            text: "system"
            color: root.cDim
            font.family: "monospace"
            font.pixelSize: 12
        }

        // cpu
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "cpu"; color: root.cDim; font.family: "monospace"; font.pixelSize: 12; Layout.preferredWidth: 36 }
            Rectangle {
                Layout.fillWidth: true
                height: 6; radius: 3
                color: root.cCard
                Rectangle {
                    height: parent.height; radius: 3
                    width: parent.width * Math.min(root.cpuPercent, 100) / 100
                    color: root.cAccent
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }
            Text { text: root.cpuPercent + "%"; color: root.cText; font.family: "monospace"; font.pixelSize: 12; Layout.preferredWidth: 42; horizontalAlignment: Text.AlignRight }
        }

        // mem
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { text: "mem"; color: root.cDim; font.family: "monospace"; font.pixelSize: 12; Layout.preferredWidth: 36 }
            Rectangle {
                Layout.fillWidth: true
                height: 6; radius: 3
                color: root.cCard
                Rectangle {
                    height: parent.height; radius: 3
                    width: parent.width * Math.min(root.memPercent, 100) / 100
                    color: root.cAccent
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                }
            }
            Text { text: root.memPercent + "%"; color: root.cText; font.family: "monospace"; font.pixelSize: 12; Layout.preferredWidth: 42; horizontalAlignment: Text.AlignRight }
        }

        Text {
            text: "up " + root.uptimeText
            color: root.cDim
            font.family: "monospace"
            font.pixelSize: 12
        }
    }

    // pushes the buttons to the bottom of the sidebar
    Item { Layout.fillHeight: true }

    // ── quick actions ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: [
                { label: "lock",   cmd: ["loginctl", "lock-session"] },
                { label: "reboot", cmd: ["systemctl", "reboot"] },
                { label: "power",  cmd: ["systemctl", "poweroff"] }
            ]

            delegate: Rectangle {
                id: btn
                required property var modelData
                Layout.fillWidth: true
                height: 38
                radius: 8
                color: hover.hovered ? root.cAccent : root.cCard
                Behavior on color { ColorAnimation { duration: 120 } }

                HoverHandler { id: hover }

                Text {
                    anchors.centerIn: parent
                    text: btn.modelData.label
                    color: hover.hovered ? "#1e1e2e" : root.cText
                    font.family: "monospace"
                    font.pixelSize: 13
                }

                TapHandler {
                    onTapped: Quickshell.execDetached(btn.modelData.cmd)
                }
            }
        }
    }

    // ── data plumbing: read /proc, poll every 2s ──
    FileView {
        id: cpuFile
        path: "/proc/stat"
        onLoaded: root.parseCpu(text())
    }
    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: root.parseMem(text())
    }
    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onLoaded: root.parseUptime(text())
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: { cpuFile.reload(); memFile.reload(); uptimeFile.reload() }
    }

    // cpu % = delta between two /proc/stat samples
    function parseCpu(content) {
        const parts = content.split("\n")[0].trim().split(/\s+/);
        let total = 0;
        for (let i = 1; i < parts.length; i++)
            total += parseInt(parts[i]);
        const idle = parseInt(parts[4]) + parseInt(parts[5]); // idle + iowait
        if (lastCpu) {
            const dTotal = total - lastCpu.total;
            const dIdle = idle - lastCpu.idle;
            cpuPercent = dTotal > 0 ? Math.round(100 * (dTotal - dIdle) / dTotal) : 0;
        }
        lastCpu = { total: total, idle: idle };
    }

    function parseMem(content) {
        const total = /MemTotal:\s+(\d+)/.exec(content);
        const avail = /MemAvailable:\s+(\d+)/.exec(content);
        if (total && avail)
            memPercent = Math.round(100 * (1 - parseInt(avail[1]) / parseInt(total[1])));
    }

    function parseUptime(content) {
        const secs = parseFloat(content.split(" ")[0]);
        const d = Math.floor(secs / 86400);
        const h = Math.floor(secs % 86400 / 3600);
        const m = Math.floor(secs % 3600 / 60);
        uptimeText = (d > 0 ? d + "d " : "") + h + "h " + m + "m";
    }
}
