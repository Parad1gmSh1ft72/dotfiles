/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

//import QtQuick 2.15
//import QtQuick.Controls 2.15
//import QtQuick.Dialogs 1.2
//import QtQuick.Layouts 1.0
//import org.kde.plasma.core 2.0 as PlasmaCore
//import org.kde.plasma.components 2.0 as PlasmaComponents
//import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
//import org.kde.draganddrop 2.0 as DragDrop
//import org.kde.kirigami 2.4 as Kirigami

import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.15
import org.kde.draganddrop 2.0 as DragDrop
import org.kde.kirigami 2.5 as Kirigami
import org.kde.iconthemes as KIconThemes
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasmoid 2.0
import org.kde.kcmutils as KCM



KCM.SimpleKCM {
    id: configGeneral

    property alias cfg_displayPosition: displayPosition.currentIndex
    property alias cfg_barsWidth: barWidth.currentText
    property alias cfg_barsSeparation: barSeparation.currentText


    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right



        Item {
            Kirigami.FormData.isSection: true
        }
        ComboBox {

            Kirigami.FormData.label: i18n("Widget Alignment")
            id: displayPosition
            visible: true
            model: [
                i18n("Bottom"),
                i18n("Top"),
            ]
            onActivated: cfg_displayPosition = currentIndex
        }

        ComboBox {

            Kirigami.FormData.label: i18n("bar width")
            id: barWidth
            //width: 150
            model: [8, 16, 24] // Lista de números permitidos

            onActivated: cfg_barsWidth = currentText
        }

        ComboBox {

            Kirigami.FormData.label: i18n("bar separation")
            id: barSeparation
            //width: 150
            model: [4, ,8, 16, 20, 24] // Lista de números permitidos

            onActivated: cfg_barsSeparation = currentText
        }


        CheckBox {
            id: labels2lines
            text: i18n("Show labels in two lines")
            visible: false // TODO
        }



        RowLayout{

            visible: false
            Button {
                text: i18n("Unhide all hidden applications")
                onClicked: {
                    plasmoid.configuration.hiddenApplications = [""];
                    unhideAllAppsPopup.text = i18n("Unhidden!");
                }
            }
            Label {
                id: unhideAllAppsPopup
            }
        }

    }
}
