import QtQuick
import Quickshell.Io
import qs

// Small circular workspace indicators (no numbers).
// Filled glowing dot = active workspace.
// Outlined dot       = occupied (has windows) but not focused.
// Faint dim dot       = empty.
// Niri-native: state comes from `niri msg event-stream`, which pushes
// updates as they happen — no polling. See niri's IPC docs.
Item {
    id: root
    readonly property int wsCount: 5
    readonly property int gap: 10
    readonly property int maxDot: 16

    // workspace id -> { idx, active, occupied }
    property var wsById: ({})
    function wsAtIdx(i) {
        for (const id in root.wsById) {
            const w = root.wsById[id]
            if (w.idx === i) return w
        }
        return null
    }

    implicitWidth: wsCount * maxDot + (wsCount - 1) * gap
    implicitHeight: maxDot

    Process {
        id: niriEvents
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                let evt
                try { evt = JSON.parse(line) } catch (e) { return }

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
        }
    }

    Process { id: wsSwitch }

    Repeater {
        model: root.wsCount

        Rectangle {
            id: dot
            required property int index
            property var ws: root.wsAtIdx(index + 1)
            property bool active: !!ws && ws.active
            property bool occupied: !!ws && ws.occupied

            width: active ? root.maxDot : 10
            height: width
            radius: width / 2
            x: index * (root.maxDot + root.gap) + (root.maxDot - width) / 2
            y: (root.implicitHeight - height) / 2

            color: active ? Theme.neonCyan
                 : occupied ? "transparent"
                 : Qt.rgba(1, 1, 1, 0.10)
            border.width: occupied && !active ? 2 : 0
            border.color: Theme.neonCyan

            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            // neon glow ring behind the active dot
            Rectangle {
                visible: dot.active
                anchors.centerIn: parent
                width: parent.width + 10
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 5
                border.color: Qt.rgba(0, 1, 0.95, 0.22)
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -5
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    wsSwitch.command = ["niri", "msg", "action", "focus-workspace", String(dot.index + 1)]
                    wsSwitch.running = true
                }
            }
        }
    }
}
