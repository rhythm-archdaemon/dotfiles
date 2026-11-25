import QtQuick
import QtQuick.Layouts
import qs.config

Item {
    id: root

    property date currentTime: new Date()
    implicitWidth: clockText.implicitWidth + 20
    implicitHeight: 24

    Text {
        id: clockText
        anchors.centerIn: parent
        text: "// " + Qt.formatDateTime(root.currentTime, Config.bar.dateFormat)
            + "  |  " + Qt.formatDateTime(root.currentTime, Config.bar.timeFormat)
        color: Theme.neonRed
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        font.bold: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }
}
