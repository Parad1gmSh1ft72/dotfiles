/*
    SPDX-FileCopyrightText: zayronxio
    SPDX-License-Identifier: GPL-3.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "components" as Components

PlasmoidItem {
    id: root
    width: 495
    height: 110

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"

    property color widgetColor: "white"
    property string icon: (weatherData.datosweather !== "0") ? weatherData.iconWeatherCurrent : "weather-none-available"

    Components.WeatherData {
      id: weatherData
    }

    Row {
       id: wrapper
       width: parent.width < parent.height*4.5 ? parent.width : parent.height*4.5
       height: width/4.5
       anchors.centerIn: parent

       Kirigami.Icon {
         source: icon
         height: parent.height*1.1
         width: height
         color: widgetColor
      }
      Item {
        width: currentDegrees.implicitWidth
        height: currentDegrees.implicitHeight
        anchors.verticalCenter: parent.verticalCenter
        Text {
          id: currentDegrees
          width: parent.width
          height: parent.height
          font.pixelSize: wrapper.height*.8
          font.bold: true
          text: (weatherData.datosweather !== "0") ? " " + Math.round(weatherData.temperaturaActual) + "°"  : " ?"
          color: widgetColor
        }
      }
      Column {
        id: man
        width: parent.width/3
        height: parent.height*.6
        anchors.verticalCenter: parent.verticalCenter

        spacing: 0
        Text {
          id: metCondText
          width: parent.width
          height: parent.height*.5
          font.pixelSize: man.height*.5
          text: " " + weatherData.weatherShottext
          verticalAlignment: Text.AlignVCenter
          font.bold: true
          color: widgetColor
        }
        Text {
          id: metCondMaxAndMin
          width: parent.width
          height: parent.height*.5
          font.pixelSize: man.height*.5
          text: (weatherData.datosweather !== "0") ? " " + Math.round(weatherData.minweatherCurrent) + " | " + Math.round(weatherData.maxweatherCurrent) : " ? | ?"
          verticalAlignment: Text.AlignVCenter
          color: widgetColor
        }
      }
   }

}
