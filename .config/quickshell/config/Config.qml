pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Typed view over shell.json. Edit the file and the shell updates live;
// any key you leave out falls back to the default declared in *Config.qml.
Singleton {
    id: root

    property alias appearance: adapter.appearance
    property alias palette: adapter.palette
    property alias bar: adapter.bar
    property alias leftSidebar: adapter.leftSidebar
    property alias rightSidebar: adapter.rightSidebar
    property alias services: adapter.services

    FileView {
        path: Quickshell.shellPath("shell.json")
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter()
        }

        adapter: JsonAdapter {
            id: adapter
            property AppearanceConfig appearance: AppearanceConfig {}
            property PaletteConfig palette: PaletteConfig {}
            property BarConfig bar: BarConfig {}
            property SidebarConfig leftSidebar: SidebarConfig {}
            property SidebarConfig rightSidebar: SidebarConfig {}
            property ServicesConfig services: ServicesConfig {}
        }
    }
}
