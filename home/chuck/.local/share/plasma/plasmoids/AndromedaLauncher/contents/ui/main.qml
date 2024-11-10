
/***************************************************************************
 *   Copyright (C) 2014-2015 by Eike Hein <hein@kde.org>                   *
 *   Copyright (C) 2021 by Prateek SU <pankajsunal123@gmail.com>           *
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

import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import org.kde.ksvg as KSvg

import org.kde.plasma.private.kicker 0.1 as Kicker

import org.kde.kirigami 2.20 as Kirigami


PlasmoidItem {
    id: kicker

    anchors.fill: parent

    signal reset

    property bool isDash: false

    preferredRepresentation: fullRepresentation

    compactRepresentation: null
    fullRepresentation: compactRepresentation

    property Item dragSource: null

    property QtObject globalFavorites: rootModel.favoritesModel
    property QtObject systemFavorites: rootModel.systemFavoritesModel

    Plasmoid.icon: Plasmoid.configuration.useCustomButtonImage ? Plasmoid.configuration.customButtonImage : Plasmoid.configuration.icon


    // onSystemFavoritesChanged: {
    //     systemFavorites.favorites = Plasmoid.configuration.favoriteSystemActions;
    // }

    function action_menuedit() {
        processRunner.runMenuEditor();
    }

    Component {
        id: compactRepresentation
        CompactRepresentation { }
    }

    Component {
        id: menuRepresentation
        MenuRepresentation { }
    }

    Kicker.RootModel {
        id: rootModel

        autoPopulate: false

        appNameFormat: 0// Plasmoid.configuration.appNameFormat
        flat: true
        sorted: true
        showSeparators: false
        appletInterface: kicker

        showAllApps: true
        showAllAppsCategorized: true
        showTopLevelItems: !kicker.isDash
        showRecentApps: true // Plasmoid.configuration.showRecentApps
        showRecentDocs: false //Plasmoid.configuration.showRecentDocs
       // showRecentContacts: Plasmoid.configuration.showRecentContacts
        recentOrdering: 0 // Plasmoid.configuration.recentOrdering

        onShowRecentAppsChanged: {
            Plasmoid.configuration.showRecentApps = showRecentApps;
        }

        onShowRecentDocsChanged: {
            Plasmoid.configuration.showRecentDocs = showRecentDocs;
        }

        // onShowRecentContactsChanged: {
        //     plasmoid.configuration.showRecentContacts = showRecentContacts;
        // }

        onRecentOrderingChanged: {
            Plasmoid.configuration.recentOrdering = recentOrdering;
        }


        

        Component.onCompleted: {
            favoritesModel.initForClient("org.kde.plasma.kicker.favorites.instance-" + Plasmoid.id)

           // kicker.logListModel("rootmodel", rootModel);
            if (!Plasmoid.configuration.favoritesPortedToKAstats) {
                if (favoritesModel.count < 1) {
                    favoritesModel.portOldFavorites(Plasmoid.configuration.favoriteApps);
                }
                Plasmoid.configuration.favoritesPortedToKAstats = true;
            }
        }

        // onFavoritesModelChanged: {
        //     if ("initForClient" in favoritesModel) {
        //         favoritesModel.initForClient("org.kde.plasma.kicker.favorites.instance-" + plasmoid.id)

        //         if (!plasmoid.configuration.favoritesPortedToKAstats) {
        //             favoritesModel.portOldFavorites(plasmoid.configuration.favoriteApps);
        //             plasmoid.configuration.favoritesPortedToKAstats = true;
        //         }
        //     } else {
        //         favoritesModel.favorites = plasmoid.configuration.favoriteApps;
        //     }

        //     favoritesModel.maxFavorites = pageSize;
        // }

        // onSystemFavoritesModelChanged: {
        //     systemFavoritesModel.enabled = false;
        //     systemFavoritesModel.favorites = plasmoid.configuration.favoriteSystemActions;
        //     systemFavoritesModel.maxFavorites = 6;
        // }

        // Component.onCompleted: {
        //     if ("initForClient" in favoritesModel) {
        //         favoritesModel.initForClient("org.kde.plasma.kicker.favorites.instance-" + plasmoid.id)

        //         if (!plasmoid.configuration.favoritesPortedToKAstats) {
        //             favoritesModel.portOldFavorites(plasmoid.configuration.favoriteApps);
        //             plasmoid.configuration.favoritesPortedToKAstats = true;
        //         }
        //     } else {
        //         favoritesModel.favorites = plasmoid.configuration.favoriteApps;
        //     }

        //     favoritesModel.maxFavorites = pageSize;
        //     rootModel.refresh();
        // }
    }

    Connections {
        target: globalFavorites

        function onFavoritesChanged() {
            Plasmoid.configuration.favoriteApps = target.favorites;
        }
    }

    Connections {
        target: systemFavorites

        function onFavoritesChanged() {
            Plasmoid.configuration.favoriteSystemActions = target.favorites;
        }
    }

    Connections {
        target: Plasmoid.configuration

        function onFavoriteAppsChanged() {
            globalFavorites.favorites = Plasmoid.configuration.favoriteApps;
        }

        function onFavoriteSystemActionsChanged() {
            systemFavorites.favorites = Plasmoid.configuration.favoriteSystemActions;
        }
    }

    Kicker.RunnerModel {
        id: runnerModel

        favoritesModel: globalFavorites
        appletInterface: kicker
        

        runners: {
            const results = ["krunner_services", "krunner_systemsettings"];

            if (kicker.isDash) {
                results.push("krunner_sessions", "krunner_powerdevil", "calculator", "unitconverter");
            }

            if (Plasmoid.configuration.useExtraRunners) {
                results.push(...Plasmoid.configuration.extraRunners);
            }

            return results;
        }
    }

    Kicker.DragHelper {
        id: dragHelper

        dragIconSize: Kirigami.Units.iconSizes.medium
    }

    Kicker.ProcessRunner {
        id: processRunner;
    }

    KSvg.FrameSvgItem {
        id: highlightItemSvg

        visible: false

        imagePath: "widgets/viewitem"
        prefix: "hover"
    }

    KSvg.FrameSvgItem {
        id: panelSvg
        visible: false
        imagePath: "widgets/panel-background"
    }

    KSvg.FrameSvgItem {
        id: dialogSvg
        visible: false
        imagePath: "dialogs/background"
    }

    PlasmaComponents.Label {
        id: toolTipDelegate

        width: contentWidth
        height: contentHeight

        property Item toolTip

        text: (toolTip != null) ? toolTip.text : ""
    }

    function resetDragSource() {
        dragSource = null;
    }

     Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Edit Applications…")
            icon.name: "kmenuedit"
            visible: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
            onTriggered: processRunner.runMenuEditor()
        }
    ]

    Component.onCompleted: {
        //plasmoid.setAction("menuedit", i18n("Edit Applications..."));
        rootModel.refreshed.connect(reset);

        dragHelper.dropped.connect(resetDragSource);
    }
}
