import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs

RowLayout {
    id: root
    spacing: 8 // Tighter spacing for a compact bar layout

    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool playing: !!root.player && root.player.playbackState === MprisPlaybackState.Playing
    readonly property string trackLabel: root.player
        ? (root.player.trackTitle || "Unknown Track")
        : "No media playing"

    // --- Compact Previous Button ---
    RowLayout {
        id: prevButton
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        Text {
            text: "["
            color: root.player && root.player.canGoPrevious ? Theme.neonMagenta : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: "\u23EE" // ⏮
            color: prevMouse.containsMouse ? Theme.textPrimary : (root.player && root.player.canGoPrevious ? Theme.neonMagenta : Theme.textDim)
            font.pixelSize: Theme.fontSize
            
            MouseArea {
                id: prevMouse
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: root.player && root.player.canGoPrevious ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: !!root.player && root.player.canGoPrevious
                onClicked: root.player.previous()
            }
        }

        Text {
            text: "]"
            color: root.player && root.player.canGoPrevious ? Theme.neonMagenta : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }    

    // --- Compact Play/Pause Button ---
    RowLayout {
        id: playButton
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        Text {
            text: "["
            color: root.player ? Theme.neonMagenta : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: root.playing ? "\u23F8" : "\u25B6" // ⏸ / ▶
            color: playMouse.containsMouse ? Theme.textPrimary : (root.player ? Theme.neonMagenta : Theme.textDim)
            font.pixelSize: Theme.fontSize
            
            MouseArea {
                id: playMouse
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: root.player ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: !!root.player
                onClicked: root.playing ? root.player.pause() : root.player.play()
            }
        }

        Text {
            text: "]"
            color: root.player ? Theme.neonMagenta : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    // --- Compact Next Button ---
    RowLayout {
        id: nextButton
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        Text {
            text: "["
            color: root.player && root.player.canGoNext ? Theme.neonMagenta : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            text: "\u23ED" // ⏭
            color: nextMouse.containsMouse ? Theme.textPrimary : (root.player && root.player.canGoNext ? Theme.neonMagenta : Theme.textDim)
            font.pixelSize: Theme.fontSize

            MouseArea {
                id: nextMouse
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: root.player && root.player.canGoNext ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: !!root.player && root.player.canGoNext
                onClicked: root.player.next()
            }
        }

        Text {
            text: "]"
            color: root.player && root.player.canGoNext ? Theme.neonMagenta : Theme.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    Text {
        text: "|"
        color: root.player && root.player.canGoNext ? Theme.neonCyan : Theme.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    // --- Track Label Container ---
    Item {
        id: labelContainer
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 130
        height: textElement.implicitHeight
        clip: true
        
        Text {
            id: textElement
            text: root.trackLabel
            color: Theme.neonMagenta
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }

            readonly property bool needsScrolling: implicitWidth > labelContainer.width
            
            x: needsScrolling ? currentX : 0
            property real currentX: 0

            // --- Reset on Pause Watcher ---
            Connections {
                target: root
                function onPlayingChanged() {
                    if (!root.playing) {
                        marqueeAnimation.stop()
                        textElement.currentX = 0
                    }
                }
            }

            SequentialAnimation on currentX {
                id: marqueeAnimation
                running: textElement.needsScrolling && root.playing
                loops: Animation.Infinite
                alwaysRunToEnd: false

                PauseAnimation { duration: 1200 }

                PropertyAnimation {
                    to: -(textElement.implicitWidth - labelContainer.width)
                    easing.type: Easing.Linear
                    duration: {
                        var distance = textElement.implicitWidth - labelContainer.width;
                        var pixelsPerSecond = 20; 
                        return (distance / pixelsPerSecond) * 1000;
                    }
                }
                
                PauseAnimation { duration: 1200 }

                PropertyAnimation {
                    to: 0
                    duration: 0
                }
            }

            onTextChanged: {
                currentX = 0
                marqueeAnimation.restart()
            }
            
            onNeedsScrollingChanged: {
                if (!needsScrolling) {
                    currentX = 0
                }
            }
        }
    }
}
