/*
SPDX-FileCopyrightText: zayronxio
SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick 2.12
import org.kde.plasma.plasmoid
import Qt5Compat.GraphicalEffects
import "js/Texts.js" as Texts

PlasmoidItem {
    id: root
    width: 500
    height: 150

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"

    FontLoader {
        id: urbanBlack
        source: "../fonts/Urban-Black.otf"
    }
    property string colorDay: Plasmoid.configuration.colordaytext
    property string colorDate: Plasmoid.configuration.colordatetext

    property string dayfullNum: Qt.formatDateTime(new Date(), "dd") + " / " + Qt.formatDateTime(new Date(), "MM")

    property string codelang: ((Qt.locale().name)[0]+(Qt.locale().name)[1])


    Column {
        width: parent.width
        height: parent.height
        Item {
            id: day
            width: parent.width
            height: parent.height*.7
            Text {
                id: dayText
                width: day.width
                height: day.height
                text: Texts.getDayWeekText(codelang, (new Date()).getDay())
                color: colorDay
                font.family: urbanBlack.name
                font.pixelSize: parent.height*.85
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        Item {
            width: parent.width
            height: parent.height*.3
            Rectangle {
                id: backgroundDayAndMonth
                color: colorDate
                width: dayAndMonth.implicitWidth*1.6
                height: dayAndMonth.implicitHeight*1.5
                radius: height
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: dayAndMonth
                    invert: true
                }
                anchors.right: parent.right
                anchors.rightMargin: (parent.width - width)/2
                Text {
                    id: dayAndMonth
                    width: parent.width
                    height: parent.height
                    text: dayfullNum
                    font.pixelSize: root.height*0.10
                    font.bold: true
                    visible: false
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    Timer {
        id: timer
        interval: 8.64e+7-((new Date().getHours()*60*60*1000)+(new Date().getMinutes()*60*1000)+(new Date().getSeconds()*1000)+new Date().getMilliseconds())
        running: true
        repeat: true
        onTriggered: {
            dayText.text = Texts.getDayWeekText(codelang, (new Date()).getDay())
            root.dayfullNum = Qt.formatDateTime(new Date(), "dd") + " / " + Qt.formatDateTime(new Date(), "MM")
            timer.interval = 86400000 - ((new Date().getHours() * 3600000) + (new Date().getMinutes() * 60000) + (new Date().getSeconds() * 1000) + new Date().getMilliseconds())
        }
    }
}
