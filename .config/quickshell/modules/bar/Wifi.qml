import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

Item {
    id: root

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: 24

    RowLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 5

        Text {
            text: "NET //"
            color: Network.isConnected ? Theme.neonBlue : Theme.neonRed
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            font.bold: true
        }
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: Network.isConnected ? "󰤨" : "󰤭"
            color: Network.isConnected ? Theme.neonBlue : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.maximumWidth: 120
            elide: Text.ElideRight
            text: Network.isConnected ? Network.activeSsid : "OFFLINE"
            color: Network.isConnected ? Theme.textPrimary : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.bold: true
        }
        Text {
            visible: Network.isConnected
            text: Network.activeSignal + "%"
            color: Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
        }
    }
}
