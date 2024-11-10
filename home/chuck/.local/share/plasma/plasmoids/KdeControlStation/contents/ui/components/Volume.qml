import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.volume as Vol

import "../lib" as Lib
import "../js/funcs.js" as Funcs

Lib.Slider {
    Layout.fillWidth: true
    Layout.preferredHeight: root.sectionHeight/2
    visible: sinkAvailable && root.showVolume
    useIconButton: true
    title: i18n("Volume")
    canTogglePage: true
    
    // Volume Feedback
    Vol.VolumeFeedback {
        id: feedback
    }
    
    // Audio source
    property var sink: Vol.PreferredDevice.sink
    readonly property bool sinkAvailable: sink && !(sink && sink.name == "auto_null")
    readonly property Vol.SinkModel paSinkModel: Vol.SinkModel {
        id: paSinkModel
    }
    
    value: Math.round(sink.volume / Vol.PulseAudio.NormalVolume * 100)
    secondaryTitle: Math.round(sink.volume / Vol.PulseAudio.NormalVolume * 100) + "%"
    
    // Changes icon based on the current volume percentage
    source: Funcs.volIconName(sink.volume, sink.muted)
    
    onValueChanged: {
        if(root.playVolumeFeedback) {
            feedback.play(sink.index)
        }
    }
    // Update volume
    onMoved: {
        sink.volume = value * Vol.PulseAudio.NormalVolume / 100
    }
    // Display view that shows audio devices list
    onTogglePage: {
        volumePage.toggleSection()
    }
    
    property var oldVol: 100 * Vol.PulseAudio.NormalVolume / 100
    onClicked: {
        if(value!=0){
            oldVol = sink.volume
            sink.volume=0
        } else {
            sink.volume=oldVol
        }
    }
}