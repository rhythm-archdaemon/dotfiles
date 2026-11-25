import Quickshell
import QtQuick
import qs.config
import qs.modules.bar
import qs.modules.dashboard
import qs.modules.control

// Entry point. Quickshell loads this file; every other directory is
// auto-exposed as a "qs.<dir>" import (qs.config, qs.services, qs.components,
// qs.modules.*). Services are singletons, so they start lazily the first time
// something references them and are shared by every screen.
ShellRoot {
    Variants {
        model: Config.bar.enabled ? Quickshell.screens : []
        Bar { modelData: modelData }
    }

    Variants {
        model: Config.leftSidebar.enabled ? Quickshell.screens : []
        LeftSidebar { modelData: modelData }
    }

    Variants {
        model: Config.rightSidebar.enabled ? Quickshell.screens : []
        RightSidebar { modelData: modelData }
    }
}
