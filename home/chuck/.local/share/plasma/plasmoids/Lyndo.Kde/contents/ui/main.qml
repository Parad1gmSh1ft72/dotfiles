import QtQuick 2.12
import QtQuick.Controls 2.15
import org.kde.plasma.plasmoid
import "components" as Components
import "js/Texts.js" as Texts
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    width: 450
    height: 150

    property color colorPlasmoid: Plasmoid.configuration.colorHex
    property color accentColor: Plasmoid.configuration.accentColor
    property string monthText: Qt.formatDateTime(new Date(), "MMMM").substring(0, 4) + ".";
    property string daytextF: Qt.formatDateTime(new Date(), "dddd").substring(0, 3);
    property string hours: Qt.formatDateTime(new Date(), "h:mmAP");
    Plasmoid.backgroundHints: "NoBackground"

    Components.WeatherData {
        id: weatherData
    }

    FontLoader {
        id: utline
        source: "../Fonts/NTOutline.ttf"
    }
    FontLoader {
        id: roboto
        source: "../Fonts/Roboto Black.ttf"
    }
    FontLoader {
        id: tuesdayNight
        source: "../Fonts/Tuesday Night.otf"
    }
    FontLoader {
        id: fivo
        source: "../Fonts/Fivo Sans Light.otf"
    }
    function eliminteZero(a) {
        if (a[0] === '0') {
            if (a[1] > '0') {
                return a[1]
            } else {
                return a
            }
        } else {
            return a
        }
    }

    Item {
        width: root.width < root.height*2.5 ? root.width : root.height*2.5
        height: width/2.5
        Text {
            id: month
            text: monthText
            anchors.left: parent.left
            anchors.leftMargin: day.implicitWidth
            font.family: utline.name
            color: colorPlasmoid
            font.capitalization: Font.Capitalize
            font.pixelSize: parent.height * .7
        }
        Text {
            id: day
            text: daytextF
            font.pixelSize: parent.height * .35
            font.family: roboto.name
            color: colorPlasmoid
            font.capitalization: Font.Capitalize
            anchors.verticalCenter: month.verticalCenter
        }
        Text {
            text: hours
            anchors.top: day.bottom
            anchors.topMargin: - day.implicitHeight*.15
            font.family: roboto.name
            color: colorPlasmoid
            renderType: Text.NativeRendering
            font.pixelSize: parent.height * .06
        }
        Text {
            id: textDay
            text: Texts.TextNumbers("en", Qt.formatDateTime(new Date(), "d"))
            font.pixelSize: parent.height * .3
            font.family: tuesdayNight.name
            color: accentColor
            anchors.left: month.left
            font.capitalization: Font.Capitalize
            anchors.leftMargin: month.implicitWidth*.09
            anchors.verticalCenter: month.verticalCenter
        }
        Rectangle {
            id: point
            width: parent.height*.01
            height: width
            radius: height/2
            anchors.top: month.bottom
            //anchors.topMargin: month.height * . 3
            anchors.left: parent.left
            color: colorPlasmoid
            anchors.leftMargin: day.implicitWidth *.95
        }
        Text {
            id: weatherInfo
            text: (weatherData.datosweather !== "0") ? weatherData.weatherShottext + " " + Math.round(weatherData.temperaturaActual) + "°" : "?"
            anchors.verticalCenter: point.verticalCenter
            anchors.left: point.right
            color: colorPlasmoid
            anchors.leftMargin: point.width * 4
            font.pixelSize: parent.height * .1
            renderType: Text.NativeRendering
            font.family: fivo.name
        }
    }
    Timer {
        id: timer
        interval: (60 - (new Date().getSeconds()))*1000
        running: true
        repeat: true
        onTriggered: {
            monthText =  Qt.formatDateTime(new Date(), "MMMM").substring(0, 4) + ".";
            hours = Qt.formatDateTime(new Date(), "h:mmAP");
            daytextF = Qt.formatDateTime(new Date(), "dddd").substring(0, 3)
            timer.interval = 60000;
        }
    }

}
