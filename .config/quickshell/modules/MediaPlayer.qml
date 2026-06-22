import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs

RowLayout {
    id: root
    spacing: 12 // Slightly wider spacing for a cleaner look

    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool playing: !!root.player && root.player.playbackState === MprisPlaybackState.Playing
    readonly property string trackLabel: root.player
        ? (root.player.trackTitle || "Unknown Track")
        : "No media playing"

    // --- Previous Button ---
    Rectangle {
        id: prevButton
        Layout.alignment: Qt.AlignVCenter
        width: 28; height: 28; radius: 6
        color: prevMouse.containsMouse ? Qt.rgba(Theme.neonMagenta.r, Theme.neonMagenta.g, Theme.neonMagenta.b, 0.15) : "transparent"
        border.width: 1.5
        border.color: root.player && root.player.canGoPrevious ? Theme.neonMagenta : Theme.textDim
        
        // Smooth hover transition
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent // Centered correctly
            text: "\u23EE" // ⏮
            color: root.player && root.player.canGoPrevious ? Theme.neonMagenta : Theme.textDim
            font.pixelSize: 14
        }

        MouseArea {
            id: prevMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.player && root.player.canGoPrevious ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: !!root.player && root.player.canGoPrevious
            onClicked: root.player.previous()
        }
    }    

    // --- Play/Pause Button ---
    Rectangle {
        id: playButton
        Layout.alignment: Qt.AlignVCenter
        width: 32; height: 32
        radius: root.playing ? 16 : 8 // Smoothly morphs from rounded square to circle
        color: playMouse.containsMouse ? Qt.rgba(Theme.neonMagenta.r, Theme.neonMagenta.g, Theme.neonMagenta.b, 0.15) : "transparent"
        border.width: 1.5
        border.color: root.player ? Theme.neonMagenta : Theme.textDim

        // Smooth structural transitions
        Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            // Offset the play icon slightly to visually center it due to its triangular shape
            anchors.horizontalCenterOffset: !root.playing ? 1 : 0 
            text: root.playing ? "\u23F8" : "\u25B6" // ⏸ / ▶
            color: root.player ? Theme.neonMagenta : Theme.textDim
            font.pixelSize: root.playing ? 14 : 12
        }

        MouseArea {
            id: playMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.player ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: !!root.player
            onClicked: root.playing ? root.player.pause() : root.player.play()
        }
    }

    // --- Next Button ---
    Rectangle {
        id: nextButton
        Layout.alignment: Qt.AlignVCenter
        width: 28; height: 28; radius: 6
        color: nextMouse.containsMouse ? Qt.rgba(Theme.neonMagenta.r, Theme.neonMagenta.g, Theme.neonMagenta.b, 0.15) : "transparent"
        border.width: 1.5
        border.color: root.player && root.player.canGoNext ? Theme.neonMagenta : Theme.textDim

        Behavior on color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent // Fixed: Moved outside MouseArea and properly centered
            text: "\u23ED" // ⏭
            color: root.player && root.player.canGoNext ? Theme.neonMagenta : Theme.textDim
            font.pixelSize: 14
        }

        MouseArea {
            id: nextMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.player && root.player.canGoNext ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: !!root.player && root.player.canGoNext
            onClicked: root.player.next()
        }
    }

    // --- Marquee Track Label ---
    Item {
        id: labelContainer
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 150
        height: textElement.implicitHeight
        clip: true // Prevents text from spilling outside the bounding box

        Text {
            id: textElement
            text: root.trackLabel
            color: Theme.neonMagenta
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize
                bold: true
            }

            // The Marquee Logic
            readonly property bool needsScrolling: implicitWidth > labelContainer.width
            x: needsScrolling ? 0 : 0 // Resets position if text fits

            SequentialAnimation on x {
                id: marqueeAnimation
                running: textElement.needsScrolling && root.playing
                loops: Animation.Infinite
                alwaysRunToEnd: false

                // Pause briefly at the start
                PauseAnimation { duration: 1000 }

                // Smoothly scroll to the left
               PropertyAnimation {
                  to: -(textElement.implicitWidth - labelContainer.width)
                  easing.type: Easing.Linear
    
                  // --- Constant Speed Logic ---
                  // Formula: (Distance to travel / Speed in pixels per second) * 1000 milliseconds
                  // Adjust the '50' below to make it faster (e.g., 70) or slower (e.g., 40)
                  duration: {
                      var distance = textElement.implicitWidth - labelContainer.width;
                      var pixelsPerSecond = 20; 
                      return (distance / pixelsPerSecond) * 1000;
                  }
                }
                // Pause briefly at the end
                PauseAnimation { duration: 1000 }

                // Quick jump/fade back to start (optional: replace with instant jump)
                PropertyAnimation {
                    to: 0
                    duration: 0
                }
            }

            // Reset animation whenever the track changes
            onTextChanged: {
                marqueeAnimation.restart()
            }
        }
    }
}
