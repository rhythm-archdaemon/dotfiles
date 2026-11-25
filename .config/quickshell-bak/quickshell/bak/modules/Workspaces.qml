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
    readonly property int wsCount: 9
    readonly property int gap: 2
    readonly property int maxDot: 10

    // workspace id -> { idx, active, occupied }
    property var wsById: ({})

    function wsAtIdx(i) {
        for (const id in root.wsById) {
            const w = root.wsById[id]
            if (w.idx === i) return w
        }
        return null
    }

    implicitWidth: wsCount * 18 + (wsCount - 1) * gap
    implicitHeight: 24

    Process {
        id: niriEvents
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                let evt
                try {
                    evt = JSON.parse(line)
                } catch (e) {
                    return
                }

                if (evt.WorkspacesChanged) {
                    const map = {}
                    for (const w of evt.WorkspacesChanged.workspaces) {
                        map[w.id] = { idx: w.idx, active: w.is_active, occupied: w.active_window_id !== null }
                    }
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

            // Explicit dimensions to contain the text and underline layout perfectly
            width: 18
            height: 20

            // Position alignment calculations matching your original gap properties
            x: index * (width + root.gap)
            y: (root.implicitHeight - height) / 2 + 2

            color: "transparent"
            border.width: 0

            // Text Number Element
            Text {
                id: numText
                anchors.centerIn: parent
                // Offset upward slightly to account for the underline space below
                anchors.verticalCenterOffset: active ? -2 : 0
                scale: active ? 1.25 : 1.0
                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

                text: (dot.index + 1)
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: active

                // Color states based on workspace conditions
                color: active ? Theme.neonCyan
                    : occupied ? Theme.textPrimary
                    : Theme.textDim // Dim placeholder text if unoccupied
            }

            // --- Active Workspace Accent Underline ---
            Rectangle {
                id: activeIndicator
                visible: dot.active
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                // Target length mirrors the numbers nicely inside the container boundaries
                width: active ? 12 : 0
                height: 2
                radius: 1
                color: Theme.neonCyan
                opacity: 0.95
                Behavior on width { NumberAnimation { duration: 160 } }

                SequentialAnimation on opacity {
                    running: dot.active
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.35; duration: 700 }
                    NumberAnimation { to: 1.0; duration: 700 }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    wsSwitch.command = ["niri", "msg", "action", "focus-workspace", String(dot.index + 1)]
                    wsSwitch.running = true
                }
            }
        }
    }
}
