/*
SPDX-FileCopyrightText: zayronxio
SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import org.kde.plasma.plasmoid
import org.kde.plasma.private.mpris as Mpris
import Qt5Compat.GraphicalEffects

PlasmoidItem {
    id: root
    width: 300
    height: 100

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"

    Mpris.Mpris2Model {
        id: mpris2Model
    }

    property color generalColor:  Plasmoid.configuration.colorGeneral
    property string artist: mpris2Model.currentPlayer?.artist ?? ""
    property string track: mpris2Model.currentPlayer?.track
    readonly property int playbackStatus: mpris2Model.currentPlayer?.playbackStatus ?? 0
    readonly property bool isPlaying: root.playbackStatus === Mpris.PlaybackStatus.Playing

    Row {
        id: wrapper
        width: root.width
        height: root.height
        visible: isPlaying
        Item {
            id: album
            width: parent.height
            height: parent.height
            Rectangle {
                width: parent.width
                height: parent.height
                radius: height/2
                color: generalColor
                anchors.centerIn: parent
                Rectangle {
                    id: mask
                    width: parent.width*.9
                    height: parent.height*.9
                    radius: 100
                    visible: true
                    color: "black"
                    anchors.centerIn: parent
                }

                Image {
                    width: mask.width
                    height: mask.height
                    source: mpris2Model.currentPlayer?.artUrl
                    visible: !mpris2Model.currentPlayer?.artUrl ? false : true
                    anchors.centerIn: parent
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: mask
                    }
                }
            }
        }

        Column {
            width: parent.width - album.width
            height: parent.height*.6
            anchors.verticalCenter: parent.verticalCenter
            Text {
                id: textTrack
                width: parent.width
                height: parent.height/2
                anchors.left: parent.left
                anchors.leftMargin: height*.5
                text: track
                elide: Text.ElideRight
                font.bold: true
                font.pixelSize: height*.7
                color: generalColor
            }
            Text {
                width: parent.width
                height: parent.height/2
                anchors.left: parent.left
                anchors.leftMargin: height*.5
                font.pixelSize: height*.7
                text: artist
                elide: Text.ElideRight
                color: generalColor
            }

        }
    }
}
