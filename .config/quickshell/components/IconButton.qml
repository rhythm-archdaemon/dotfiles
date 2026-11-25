import QtQuick
import qs.config

// Square glyph button (transport controls etc.). Uses Item.enabled for the disabled state.
Rectangle {
    id: btn

    property string glyph: ""
    property color tint: Theme.neonMagenta
    signal activated()

    width: 38
    height: 34
    radius: 2
    opacity: enabled ? 1 : 0.35
    color: mouse.containsMouse && enabled ? tint : Qt.rgba(tint.r, tint.g, tint.b, 0.06)
    border.width: 1
    border.color: tint
    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        anchors.centerIn: parent
        text: btn.glyph
        color: mouse.containsMouse && btn.enabled ? Theme.bgPanel : btn.tint
        font.pixelSize: 15
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.activated()
    }
}
