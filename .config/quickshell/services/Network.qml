pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// NetworkManager (nmcli) state: active link, visible networks, saved profiles.
Singleton {
    id: root

    property string activeSsid: ""
    property int activeSignal: 0
    readonly property bool isConnected: activeSsid !== ""

    property var networks: []       // [{ ssid, signal, secured, active }]
    property var savedNetworks: []  // [{ ssid, saved: true, secured: true, active: false }]

    // nmcli -t escapes ':' and '\' inside fields with a backslash.
    function splitTerse(line) {
        const out = []
        let cur = ""
        for (let i = 0; i < line.length; i++) {
            const c = line[i]
            if (c === "\\" && i + 1 < line.length) {
                cur += line[i + 1]
                i++
            } else if (c === ":") {
                out.push(cur)
                cur = ""
            } else {
                cur += c
            }
        }
        out.push(cur)
        return out
    }

    function refreshStatus() { if (!statusProc.running) statusProc.running = true }
    function scan() { scanProc.running = true }
    function loadSaved() { savedProc.running = true }
    function refreshAll() { scan(); loadSaved(); refreshStatus() }

    function connectTo(ssid, password) {
        connectProc.command = password
            ? ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "dev", "wifi", "connect", ssid]
        connectProc.running = true
    }

    function reconnectTo(profile) {
        connectProc.command = ["nmcli", "connection", "up", "id", profile]
        connectProc.running = true
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "nmcli -t -f active,ssid,signal dev wifi | grep '^yes' | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = root.splitTerse(this.text.trim())
                if (parts.length >= 3 && parts[0] === "yes") {
                    root.activeSsid = parts[1]
                    root.activeSignal = parseInt(parts[2]) || 0
                } else {
                    root.activeSsid = ""
                    root.activeSignal = 0
                }
            }
        }
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,ACTIVE", "dev", "wifi", "list", "--rescan", "yes"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = new Set()
                const list = []
                for (const line of this.text.trim().split("\n")) {
                    const f = root.splitTerse(line)
                    if (!f[0] || seen.has(f[0])) continue
                    seen.add(f[0])
                    list.push({
                        ssid: f[0],
                        signal: parseInt(f[1]) || 0,
                        secured: !!f[2] && f[2] !== "--",
                        active: f[3] === "yes"
                    })
                }
                list.sort((a, b) => (a.active !== b.active) ? (a.active ? -1 : 1) : b.signal - a.signal)
                root.networks = list.slice(0, 15)
            }
        }
    }

    Process {
        id: savedProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = []
                for (const line of this.text.trim().split("\n")) {
                    if (!line) continue
                    const f = root.splitTerse(line)
                    if (f.length < 2 || f[f.length - 1] !== "802-11-wireless") continue
                    const name = f.slice(0, -1).join(":")
                    if (name) list.push({ ssid: name, saved: true, secured: true, active: false })
                }
                root.savedNetworks = list
            }
        }
    }

    Process {
        id: connectProc
        onExited: root.refreshStatus()
    }

    Timer {
        interval: Config.services.networkPollMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshStatus()
    }
}
