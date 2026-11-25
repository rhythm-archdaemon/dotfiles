pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default PipeWire sink volume.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: !!(sink && sink.ready && sink.audio)
    readonly property int percent: ready ? Math.round(sink.audio.volume * 100) : 0

    function setPercent(p) {
        if (ready) sink.audio.volume = p / 100
    }

    PwObjectTracker { objects: [root.sink] }
}
