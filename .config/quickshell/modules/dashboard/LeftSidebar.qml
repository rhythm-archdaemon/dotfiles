import QtQuick
import QtQuick.Layouts
import qs.config
import qs.components

SlideSidebar {
    side: "left"
    accent: Theme.neonCyan
    title: "// LEFT RAIL // CORE SYSTEMS"
    expandedWidth: Config.leftSidebar.width

    UserInfo { Layout.fillWidth: true }
    MediaPlayer { Layout.fillWidth: true }

    ChannelSlider { kind: "volume" }
    ChannelSlider { kind: "brightness" }

    SystemInfo { Layout.fillWidth: true }

    Item { Layout.fillHeight: true }
}
