import QtQuick
import QtQuick.Controls
import qs.config

TextField {
    color: Theme.textPrimary
    placeholderTextColor: Theme.textPrimary
    font.family: Theme.fontFamily
    background: Rectangle {
        radius: 3
        color: Theme.bgPanel
        border.width: 1
        border.color: Theme.neonGreen
    }
}
