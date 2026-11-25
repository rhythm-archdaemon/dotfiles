pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

// BlueZ state via Quickshell's native Bluetooth module (no bluetoothctl parsing).
// Named BluetoothStatus because "Bluetooth" is already Quickshell's own singleton.
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: !!adapter
    readonly property bool powered: !!adapter && adapter.enabled
    readonly property bool scanning: !!adapter && adapter.discovering

    // Connected first, then paired, then nearby; unnamed devices (name == MAC) are hidden
    // unless already paired, so the list isn't flooded with random beacons.
    readonly property var devices: {
        if (!adapter) return []
        const list = []
        for (const d of Bluetooth.devices.values) {
            const named = !!d.name && d.name !== d.address.replace(/:/g, "-")
            if (named || d.paired || d.connected) list.push(d)
        }
        list.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            if (a.paired !== b.paired) return a.paired ? -1 : 1
            return (a.name || "").localeCompare(b.name || "")
        })
        return list
    }

    function isBusy(d) {
        return d.pairing
            || d === root.retryDevice
            || d.state === BluetoothDeviceState.Connecting
            || d.state === BluetoothDeviceState.Disconnecting
    }

    function setPowered(on) { if (adapter) adapter.enabled = on }
    function startScan() { if (adapter && adapter.enabled) { adapter.discovering = true; scanTimeout.restart() } }
    function stopScan() { if (adapter) adapter.discovering = false; scanTimeout.stop() }
    function toggleScan() { scanning ? stopScan() : startScan() }

    // ── connect with retry ───────────────────────────────────────────
    // Connecting in the same instant BlueZ reports "paired" gets the link dropped
    // ("Connection terminated by local host"). So: trust first, wait a moment,
    // connect, check it stuck, and retry a couple of times if it didn't.
    property var retryDevice: null
    property int attempts: 0
    readonly property int maxAttempts: 3

    function connectWithRetry(d, delayMs) {
        d.trusted = true
        retryDevice = d
        attempts = 0
        connectDelay.interval = Math.max(1, delayMs)
        connectDelay.restart()
    }

    Timer {
        id: connectDelay
        onTriggered: {
            const d = root.retryDevice
            if (!d) return
            if (d.connected) { root.retryDevice = null; return }
            root.attempts++
            d.connect()
            verify.restart()
        }
    }

    Timer {
        id: verify
        interval: 4000
        onTriggered: {
            const d = root.retryDevice
            if (!d) return
            if (d.connected || root.attempts >= root.maxAttempts) {
                root.retryDevice = null
            } else {
                connectDelay.interval = 1000
                connectDelay.restart()
            }
        }
    }

    // ── pairing ──────────────────────────────────────────────────────
    property var pending: null

    function pair(d) {
        pending = d
        d.pair()
    }

    function primaryAction(d) {
        if (d.connected) {
            retryDevice = null
            d.disconnect()
        } else if (d.paired) {
            connectWithRetry(d, 1)
        } else {
            pair(d)
        }
    }

    function forget(d) {
        if (retryDevice === d) retryDevice = null
        d.forget()
    }

    Connections {
        target: root.pending
        ignoreUnknownSignals: true
        function onPairedChanged() {
            const d = root.pending
            if (d && d.paired) {
                root.pending = null
                root.connectWithRetry(d, 1500)
            }
        }
    }

    // Discovery drains the radio and competes with A2DP audio; don't leave it running.
    Timer {
        id: scanTimeout
        interval: 30000
        onTriggered: root.stopScan()
    }
}
