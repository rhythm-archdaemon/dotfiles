pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// mako notification list (active + history) via makoctl.
Singleton {
    id: root

    property var entries: []

    function refresh() {
        if (!activeProc.running) activeProc.running = true
        if (!historyProc.running) historyProc.running = true
    }

    function dismiss(id) {
        commandProc.command = ["makoctl", "dismiss", "-n", String(id)]
        commandProc.running = true
        Qt.callLater(refresh)
    }

    function clearAll() {
        commandProc.command = ["makoctl", "dismiss", "--all"]
        commandProc.running = true
        root.entries = []
    }

    function invoke(id, action) {
        commandProc.command = ["makoctl", "invoke", "-n", String(id), action]
        commandProc.running = true
    }

    function update(json, fromHistory) {
        let parsedJson
        try {
            parsedJson = JSON.parse(json)
        } catch (error) {
            return
        }
        if (!Array.isArray(parsedJson)) return

        const other = root.entries.filter(n => n.fromHistory !== fromHistory)
        const parsed = parsedJson.map(n => ({
            id: n.id,
            appName: n["app-name"] || n.appName || "notification",
            summary: n.summary || "",
            body: n.body || "",
            urgency: n.urgency || "normal",
            actions: (n.actions || []).map(a => ({
                text: a.name || a.text || a.id || "",
                id: a.id || a.identifier || ""
            })),
            fromHistory: fromHistory
        }))
        root.entries = other.concat(parsed)
    }

    Process {
        id: activeProc
        command: ["makoctl", "list", "-j"]
        stdout: StdioCollector { onStreamFinished: root.update(this.text, false) }
    }

    Process {
        id: historyProc
        command: ["makoctl", "history", "-j"]
        stdout: StdioCollector { onStreamFinished: root.update(this.text, true) }
    }

    Process { id: commandProc }

    Timer {
        interval: Config.services.notificationPollMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
