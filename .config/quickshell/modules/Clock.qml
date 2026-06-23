import QtQuick
import QtQuick.Layouts
import qs

Text {
    id: clockText
    
    // Grabs time updates natively every second
    text: Qt.formatDateTime(new Date(), "dddd, MMM - dd | hh : mm AP")
    
    color: Theme.neonRed
    font {
        family: Theme.fontFamily
        pixelSize: Theme.fontSize
        bold: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "dddd, MMM - dd | hh : mm AP")
    }
}
