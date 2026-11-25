import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components
import qs.modules.notifications

SlideSidebar {
    side: "right"
    accent: Theme.neonMagenta
    title: "// RIGHT RAIL // NETWORK & ALERTS"
    expandedWidth: Config.rightSidebar.width
    wantsKeyboard: true

    WifiConnect { Layout.fillWidth: true; containerHeight: 300 }

    BluetoothConnect { Layout.fillWidth: true; containerHeight: 280 }

    // takes whatever height is left, never smaller than 160
    NotificationPanel { Layout.fillWidth: true; Layout.fillHeight: true; Layout.minimumHeight: 160 }

    PowerRow { Layout.fillWidth: true }
}
