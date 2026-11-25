pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Workspace state from niri's event stream (push-based, no polling).
Singleton {
    id: root

    // workspace id -> { idx, active, occupied }
    property var wsById: ({})

    function wsAtIdx(i) {
        for (const id in root.wsById) {
            const w = root.wsById[id]
            if (w.idx === i) return w
        }
        return null
    }

    function focusWorkspace(idx) {
        switchProc.command = ["niri", "msg", "action", "focus-workspace", String(idx)]
        switchProc.running = true
    }

    function handleEvent(line) {
        let evt
        try {
            evt = JSON.parse(line)
        } catch (e) {
            return
        }

        if (evt.WorkspacesChanged) {
            const map = {}
            for (const w of evt.WorkspacesChanged.workspaces)
                map[w.id] = { idx: w.idx, active: w.is_active, occupied: w.active_window_id !== null }
            root.wsById = map
        } else if (evt.WorkspaceActivated) {
            const targetId = evt.WorkspaceActivated.id
            const map = {}
            for (const id in root.wsById) {
                const w = root.wsById[id]
                map[id] = { idx: w.idx, active: Number(id) === targetId, occupied: w.occupied }
            }
            root.wsById = map
        } else if (evt.WorkspaceActiveWindowChanged) {
            const targetId = evt.WorkspaceActiveWindowChanged.workspace_id
            const hasWindow = evt.WorkspaceActiveWindowChanged.active_window_id !== null
            const map = {}
            for (const id in root.wsById) {
                const w = root.wsById[id]
                map[id] = (Number(id) === targetId)
                    ? { idx: w.idx, active: w.active, occupied: hasWindow }
                    : w
            }
            root.wsById = map
        }
    }

    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser { onRead: line => root.handleEvent(line) }
    }

    Process { id: switchProc }
}
