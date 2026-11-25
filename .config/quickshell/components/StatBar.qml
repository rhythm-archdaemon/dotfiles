import QtQuick
import QtQuick.Layouts
import qs.config

// "LABEL [=====     ] [ 42% ]" resource row.
RowLayout {
    id: root

    property string label: ""
    property int percent: 0
    property color tint: Theme.neonGreen
    property color labelColor: Theme.neonGreen

    Layout.fillWidth: true
    spacing: 10

    Text {
        text: root.label
        color: root.labelColor
        font.family: Theme.fontFamily
        font.bold: true
        font.pixelSize: 10
        Layout.preferredWidth: 34
    }

    Rectangle {
        Layout.fillWidth: true
        height: 8
        radius: 1
        color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.10)
        border.width: 1
        border.color: Qt.rgba(root.tint.r, root.tint.g, root.tint.b, 0.35)

        Rectangle {
            height: parent.height
            radius: 1
            width: parent.width * Math.min(root.percent, 100) / 100
            color: root.tint
            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        }
    }

    Text {
        text: "[ " + root.percent + "% ]"
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        Layout.preferredWidth: 48
        horizontalAlignment: Text.AlignRight
    }
}
