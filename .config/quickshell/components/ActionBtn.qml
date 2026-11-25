import QtQuick
import qs.config

// Small outlined text button. Uses Item.enabled for the disabled state.
Rectangle {
    id: btn

    property string label: ""
    property color tint: Theme.neonGreen
    signal activated()

    implicitWidth: lbl.implicitWidth + 14
    implicitHeight: 24
    radius: 3
    opacity: enabled ? 1 : 0.5
    color: mouse.containsMouse && enabled ? tint : "transparent"
    border.width: 1
    border.color: tint
    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: lbl
        anchors.centerIn: parent
        text: btn.label
        color: mouse.containsMouse && btn.enabled ? Theme.bgPanel : btn.tint
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: 11
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.activated()
    }
}
