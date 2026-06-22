import Quickshell
import QtQuick
import qs.modules

// Quickshell looks for this file. Everything else lives in modules/
// and is auto-imported as the "qs.modules" namespace (and Theme.qml,
// at the root, as plain "qs").
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }
}
