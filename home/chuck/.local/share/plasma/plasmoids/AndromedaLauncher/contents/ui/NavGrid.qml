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
import QtQuick 2.12

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0

import org.kde.draganddrop 2.0

FocusScope {
  id: navGrid

  signal keyNavUp
  signal keyNavDown

  property alias triggerModel: listView.model
  property alias count: listView.count
  property alias currentIndex: listView.currentIndex
  property alias currentItem: listView.currentItem
  property alias contentItem: listView.contentItem
  property Item flickableItem: listView
  property int subIndex: 0

  onFocusChanged: {
      if (!focus) {
          currentIndex = -1;
      }
  }
  function setFocus() {
    currentIndex = 0
    focus = true
    runnerList.currentMainIndex = currentIndex
  }
  function setFocusLast() {
    if (count > 0) {
      currentIndex = count - 1
      focus = true
      runnerList.currentMainIndex = currentIndex
    } else {
      setFocus()
    }
  }

  ListView {
    anchors.fill: parent
    id: listView
    currentIndex: -1
    focus: true
    // keyNavigationEnabled: true
    // highlightFollowsCurrentItem: true
    // highlightMoveDuration: 0
    snapMode: ListView.SnapToItem
    interactive: false
    // clip: false


    delegate: GenericItem {
      x: 20
      canNavigate: true
      canDrag: false
      triggerModel: listView.model
      subIndex: navGrid.subIndex
    }
  
    onCurrentIndexChanged: {
      if (currentIndex != -1) {
        focus = true;
      }
    }
    onModelChanged: {
      currentIndex = -1;
    }
    onFocusChanged: {
      if (!focus) {
        currentIndex = -1
      }
    }
    Keys.onUpPressed: {
      
      if (runnerList.currentSubIndex != subIndex) {
        repeater.itemAt(runnerList.currentSubIndex).nGrid.currentIndex = -1
      }
      if (currentIndex > 0) {
        event.accepted = true;
        currentIndex = currentIndex - 1
        runnerList.currentMainIndex = currentIndex
        runnerList.currentSubIndex = subIndex
        positionViewAtIndex(currentIndex, ListView.Contain);
      } else {
        navGrid.keyNavUp();
      }
    }
    Keys.onDownPressed: {
      if (runnerList.currentSubIndex != subIndex) {
        repeater.itemAt(runnerList.currentSubIndex).nGrid.currentIndex = -1
      }
      if (currentIndex < count - 1) { // si no ha llegado al ultimo elemento de la lists incrementa currentIndex para pasar al siguiente elemento de la lista
        event.accepted = true;
        currentIndex = currentIndex + 1;
        runnerList.currentMainIndex = currentIndex
        runnerList.currentSubIndex = subIndex
        positionViewAtIndex(currentIndex, ListView.Contain);
      } else {
        navGrid.keyNavDown();
      }
    }
    Keys.onPressed: {
      if (event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
        event.accepted = true;
        if (currentItem){
          currentItem.trigger()
        }
      }
    }
  }
}
