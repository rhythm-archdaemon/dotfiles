import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: root

    property date currentTime: new Date()
    implicitWidth: clockText.implicitWidth + 20
    implicitHeight: 24

    Text {
        id: clockText
        anchors.centerIn: parent
        text: "// " + Qt.formatDateTime(root.currentTime, "ddd dd MMM") + "  |  " + Qt.formatDateTime(root.currentTime, "HH:mm")
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
