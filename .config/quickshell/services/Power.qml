pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Session actions. Commands are configurable in shell.json (services.*Command).
Singleton {
    id: root

    function run(proc, command) {
        proc.command = command
        proc.running = true
    }

    function lock()     { run(lockProc, Config.services.lockCommand) }
    function reboot()   { run(rebootProc, Config.services.rebootCommand) }
    function poweroff() { run(poweroffProc, Config.services.poweroffCommand) }

    Process { id: lockProc }
    Process { id: rebootProc }
    Process { id: poweroffProc }
}
