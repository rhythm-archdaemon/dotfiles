pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var dev: UPower.displayDevice
    readonly property bool present: !!dev && dev.isLaptopBattery
    readonly property int percent: dev ? Math.round(dev.percentage * 100) : 0
    readonly property bool charging: !!dev
        && (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.PendingCharge)
    readonly property bool full: !!dev && dev.state === UPowerDeviceState.FullyCharged
}
