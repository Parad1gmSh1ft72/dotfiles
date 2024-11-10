/*****************************************************************************
 *   Copyright (C) 2022 by Friedrich Schriewer <friedrich.schriewer@gmx.net> *
 *                                                                           *
 *   This program is free software; you can redistribute it and/or modify    *
 *   it under the terms of the GNU General Public License as published by    *
 *   the Free Software Foundation; either version 2 of the License, or       *
 *   (at your option) any later version.                                     *
 *                                                                           *
 *   This program is distributed in the hope that it will be useful,         *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 *   GNU General Public License for more details.                            *
 *                                                                           *
 *   You should have received a copy of the GNU General Public License       *
 *   along with this program; if not, write to the                           *
 *   Free Software Foundation, Inc.,                                         *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .          *
 ****************************************************************************/
import QtQuick 2.15
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.coreaddons 1.0 as KCoreAddons

import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kirigami as Kirigami

Item {
  id: main
  property bool searching: (searchBar.text != "")
  signal  newTextQuery(string text)

  readonly property color textColor: Kirigami.Theme.textColor
  readonly property string textFont: plasmoid.configuration.useSystemFontSettings ? Kirigami.Theme.defaultFont : "SF Pro Text"
  readonly property real textSize: plasmoid.configuration.useSystemFontSettings ? Kirigami.Theme.defaultFont.pointSize : 11
  readonly property color bgColor: Kirigami.Theme.backgroundColor
  readonly property color highlightColor: Kirigami.Theme.highlightColor
  readonly property color highlightedTextColor: Kirigami.Theme.highlightedTextColor
  readonly property bool isTop: plasmoid.location == PlasmaCore.Types.TopEdge & plasmoid.configuration.launcherPosition != 2 & !plasmoid.configuration.floating

  readonly property color glowColor1: plasmoid.configuration.glowColor == 0 ? "#D300DC" :
                                      plasmoid.configuration.glowColor == 1 ? "#20bdff" :
                                      "#ff005d"
  readonly property color glowColor2: plasmoid.configuration.glowColor == 0 ? "#8700FF" :
                                      plasmoid.configuration.glowColor == 1 ? "#5433ff" :
                                      "#ff8b26"

  property bool showAllApps: false

  KCoreAddons.KUser {
      id: kuser
  }

  P5Support.DataSource {
      id: pmEngine
      engine: "powermanagement"
      connectedSources: ["PowerDevil", "Sleep States"]
      function performOperation(what) {
          var service = serviceForSource("PowerDevil")
          var operation = service.operationDescription(what)
          service.startOperationCall(operation)
      }
  }

  function updateStartpage(){
    appList.currentStateIndex = plasmoid.configuration.defaultPage
  }

  function reload() {
    searchBar.clear()
    searchBar.focus = true
    appList.reset()
  }
  function reset(){
    searchBar.clear()
    searchBar.focus = true
    appList.reset()
  }

  Rectangle {
    id: backdrop
    x: 0
    y: 125 * 1
    width: main.width
    height: isTop ? main.height - y - Kirigami.Units.largeSpacing : main.height - y - (searchBarContainer.height + 20)
    color: bgColor
    opacity: 0
  }
  //Floating Avatar
  Item {
    id: avatarParent
    x: main.width / 2
    y: - root.margins.top
    FloatingAvatar { //Anyone looking for an unpredictable number generator?
      id: floatingAvatar
      //visualParent: root
      isTop: main.isTop
      avatarWidth: 125 * 1
      visible: root.visible && !isTop ? true : root.visible && plasmoid.configuration.floating ? true : false
    }
  }
  //Power & Settings
  RowLayout {
    id: headerBar
    width: main.width
    UserAvatar {
      width: plasmoid.configuration.enableGlow ? 45 : 50
      height: width
      //Layout.leftMargin: root.margins.left
      Layout.topMargin: Kirigami.Units.mediumSpacing
      visible: !floatingAvatar.visible
    }

    Greeting {
      id: greetingTop
      Layout.fillHeight: false
      Layout.fillWidth: true
      Layout.topMargin: -10
      Layout.leftMargin: 10
      Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
      textSize: main.fontSize
      visible: !floatingAvatar.visible
    }

    Header {
      id: powerSettings
      iconSize: 20 
      Layout.fillHeight: false
      Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
    }

  }

  Rectangle {
    id: headerBarFill
    height: headerBar.height + searchBarContainer.height + 25 + fs.innerPadding
    width: mainItem.width
    color: Qt.rgba(main.bgColor.r, main.bgColor.g, main.bgColor.b, 0.3)
    x: - fs.innerPadding
    y: - fs.innerPadding
    visible: isTop
    z: -1
  }
  
  //Greeting
  Greeting {
    id: greeting
    visible: floatingAvatar.visible
    x: main.width / 2 - textWidth / 2 //This centeres the Text
    y: 70 
    textSize: 25 
  }
  //Searchbar
  Item {
    Rectangle {
      id: searchBarContainer
      y: isTop ? headerBar.height + 10 : main.height - height 
      width: main.width
      height: 45
      radius: 8
      color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.5) // better contrast color 
      Image {
        id: searchIcon
        x: 15
        width: 15
        height: width
        anchors.verticalCenter: parent.verticalCenter
        source: 'icons/feather/search.svg'
        ColorOverlay {
          visible: true
          anchors.fill: searchIcon
          source: searchIcon
          color: main.textColor
        }
      }
      Rectangle {
        x: parent.x + 45
        width: parent.width - 60
        height: searchBar.height
        anchors.verticalCenter: parent.verticalCenter
        clip: true
        color: 'transparent'
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            hoverEnabled: true
        }
        TextInput {
          id: searchBar
          width: parent.width
          anchors.verticalCenter: parent.verticalCenter
          focus: true
          color: textColor
          selectByMouse: true
          selectionColor: highlightColor
          font.family: textFont
          font.pixelSize: 13 * 1
          Text {
            anchors.fill: parent
            text: i18n("Search your computer")
            color: Kirigami.Theme.disabledTextColor
            visible: !parent.text
          }
          onTextChanged: {
              runnerModel.query = text;
              newTextQuery(text)
          }
          function clear() {
              text = "";
          }
          function backspace() {
              if (searching) {
                  text = text.slice(0, -1);
              }
              focus = true;
          }
          function appendText(newText) {
              if (!root.visible) {
                  return;
              }
              focus = true;
              text = text + newText;
          }
          Keys.onPressed: {
            if (event.key == Qt.Key_Down) {
              event.accepted = true;
              runnerList.setFocus()
            } else if (event.key == Qt.Key_Tab || event.key == Qt.Key_Up) {
              event.accepted = true;
              runnerList.setFocus()
            } else if (event.key == Qt.Key_Escape) {
              event.accepted = true;
              if (searching) {
                clear()
              } else {
                root.toggle()
              }
            } else if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
              runnerList.setFocus()
              runnerList.triggerFirst()
            }
          }
        }
      }
    }
  }

  // Fvorites / All apps label

  Image {
    id: headerLabel
    source: "icons/feather/star.svg"
    width: 15
    height: width
    y: backdrop.y + width
    anchors.topMargin:  Kirigami.Units.largeSpacing
    anchors.left: parent.left
    
    PlasmaComponents.Label {
      id: mainLabelGrid
      x: parent.width + 10
      anchors.verticalCenter: parent.verticalCenter
      text: i18n(showAllApps ? "All apps" : "Favorite Apps")
      font.family: textFont
      font.pointSize: textSize
    }

    ColorOverlay {
      visible: true
      anchors.fill: headerLabel
      source: headerLabel
      color: main.textColor
    }
  }
  // Show all app buttons
  PlasmaComponents.Button  {
      MouseArea {
          hoverEnabled: true
          anchors.fill: parent
          cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
          onClicked: showAllApps = !showAllApps
      }
      text: i18n(showAllApps ? "Back" : "All apps")
      id: mainsecLabelGrid
      icon.name: showAllApps ? "go-previous" : "go-next"
      font.pointSize: textSize
      font.family: textFont
      icon.height: 15
      icon.width: icon.height
      LayoutMirroring.enabled: true
      LayoutMirroring.childrenInherit: !showAllApps 
      flat: false
      background: Rectangle {
        color: Qt.lighter(Kirigami.Theme.backgroundColor)
        border.width: 1
        border.color: Qt.darker(Kirigami.Theme.backgroundColor, 1.14)
        radius: plasmoid.configuration.enableGlow ? height / 2 : 5

        Rectangle {
          id: bgMask
          width: parent.width
          height: parent.height
          radius: height / 2
          border.width: 0
          visible: plasmoid.configuration.enableGlow && !searching
        }
        Item {
          visible: plasmoid.configuration.enableGlow && !searching
          anchors.fill: bgMask
          // x: container.x - 20
          layer.enabled: true
          layer.effect: OpacityMask {
              maskSource: bgMask
          }

          LinearGradient {
              anchors.fill: parent
              start: Qt.point(bgMask.width, 0)
              end: Qt.point(0, bgMask.height)
              gradient: Gradient {
                  GradientStop { position: 0.0; color: glowColor1 }
                  GradientStop { position: 1.0; color: glowColor2 }
              }
          }
        }

      }
      topPadding: 5
      bottomPadding: topPadding
      leftPadding: 8
      rightPadding: 8
      icon{
          width: height
          height: visible ? Kirigami.Units.iconSizes.small : 0
          name: showAllApps ? "go-previous" : "go-next"
      }

      anchors {
        topMargin: Kirigami.Units.smallSpacing
        verticalCenter: headerLabel.verticalCenter
        // rightMargin: Kirigami.Units.largeSpacing 
        // leftMargin: Kirigami.Units.largeSpacing 
        // right: parent.right
      }
      x: main.width - (width )
      visible: !searching
  }
  // All apps button shadow
  DropShadow {
      anchors.fill: mainsecLabelGrid
      cached: true
      horizontalOffset: 0
      verticalOffset: 0
      radius: 11.0
      samples: 16
      color: glowColor1
      source: mainsecLabelGrid
      visible: plasmoid.configuration.enableGlow && !searching
  }

  //List of Apps
  AppList {
    id: appList
    state: "visible"
    anchors.top: headerLabel.bottom
    anchors.topMargin: showAllApps ? headerLabel.width : headerLabel.width * 1.5
    
    width: main.width
    height: backdrop.height - (headerLabel.height * 3.4) 
    visible: opacity > 0
    states: [
    State {
      name: "visible"; when: (!searching)
      PropertyChanges { target: appList; opacity: 1.0 }
    },
    State {
      name: "hidden"; when: (searching)
      PropertyChanges { target: appList; opacity: 0.0}
    }]
    transitions: [
      Transition {
        to: "visible"
        PropertyAnimation {properties: 'opacity'; duration: 100; easing.type: Easing.OutQuart}
      },
      Transition {
        to: "hidden"
        PropertyAnimation {properties: 'opacity'; duration: 100; easing.type: Easing.OutQuart}
      }
    ]
  }
  RunnerList {
    id: runnerList
    model: runnerModel
    state: "hidden"
    visible: opacity > 0
    anchors.top: headerLabel.bottom
    anchors.topMargin: headerLabel.width 
    width: main.width - 30 * 1
    height: backdrop.height - (headerLabel.height * 3.5)
    states: [
    State {
      name: "visible"; when: (searching)
      PropertyChanges { target: runnerList; opacity: 1.0 }
      PropertyChanges { target: runnerList; x: 20  * 1}
    },
    State {
      name: "hidden"; when: (!searching)
      PropertyChanges { target: runnerList; opacity: 0.0}
      PropertyChanges { target: runnerList; x: 40 * 1}
    }]
    transitions: [
      Transition {
        to: "visible"
        PropertyAnimation {properties: 'opacity'; duration: 100; easing.type: Easing.OutQuart}
        PropertyAnimation {properties: 'x'; from: 80 * 1; duration: 100; easing.type: Easing.OutQuart}
      },
      Transition {
        to: "hidden"
        PropertyAnimation {properties: 'opacity'; duration: 100; easing.type: Easing.OutQuart}
        PropertyAnimation {properties: 'x'; from: 20 * 1; duration: 100; easing.type: Easing.OutQuart}
      }
    ]
  }

  Keys.onPressed: {
    if (event.key == Qt.Key_Backspace) {
        event.accepted = true;
        if (searching)
            searchBar.backspace();
        else
            searchBar.focus = true
    } else if (event.key == Qt.Key_Escape) {
        event.accepted = true;
        if (searching) {
            searchBar.clear()
        } else {
            root.toggle()
        }
    } else if (event.text != "" || event.key == Qt.Key_Down) {
        if (event.key != Qt.Key_Return){
          event.accepted = true;
          searchBar.appendText(event.text);
        }
    }
  }
}
