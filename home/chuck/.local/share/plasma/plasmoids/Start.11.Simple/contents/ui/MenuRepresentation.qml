/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.4
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.components 3.0 as PC3

import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.coreaddons 1.0 as KCoreAddons // kuser
//import org.kde.plasma.private.shell 2.0
import org.kde.plasma.private.sessions as Sessions
//import org.kde.kwindowsystem 1.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.private.quicklaunch 1.0
import QtQuick.Controls 2.15
import org.kde.kirigami as Kirigami
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid
import Qt5Compat.GraphicalEffects

Item {
    id: main
    property int sizeImage: Kirigami.Units.iconSizes.large * 2
    property int menuPos: Plasmoid.configuration.displayPosition
    property int observerTab: tab.activeTab
    onVisibleChanged: {
        root.visible = !root.visible
    }

    PlasmaExtras.Menu {
        id: contextMenu

        PlasmaExtras.MenuItem {
            action: Plasmoid.internalAction("configure")
        }
    }

    Plasmoid.status: root.visible ? PlasmaCore.Types.RequiresAttentionStatus : PlasmaCore.Types.PassiveStatus

    PlasmaCore.Dialog {
        id: root

        objectName: "popupWindow"
        flags: Qt.WindowStaysOnTopHint
        //flags: Qt.Dialog | Qt.FramelessWindowHint
        location: PlasmaCore.Types.Floating
        hideOnWindowDeactivate: true

        property int iconSize: Kirigami.Units.iconSizes.large
        property int cellSizeHeight: iconSize
                                     + Kirigami.Units.gridUnit * 2
                                     + (2 * Math.max(highlightItemSvg.margins.top + highlightItemSvg.margins.bottom,
                                                     highlightItemSvg.margins.left + highlightItemSvg.margins.right))
        property int cellSizeWidth: cellSizeHeight

        property bool searching: (searchField.text != "")

        property bool showFavorites

        onVisibleChanged: {
            if (visible) {
                root.showFavorites = Plasmoid.configuration.showFavoritesFirst
                var pos = popupPosition(width, height);
                x = pos.x;
                y = pos.y;
                reset();
                animation1.start()
            }else{
                rootItem.opacity = 0
            }
        }

        onHeightChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        onWidthChanged: {
            var pos = popupPosition(width, height);
            x = pos.x;
            y = pos.y;
        }

        function toggle(){
            main.visible =  !main.visible
        }


        function reset() {
            searchField.text = "";

            if(showFavorites)
                globalFavoritesGrid.tryActivate(0,0)
            else
                mainColumn.visibleGrid.tryActivate(0,0)


        }

        function popupPosition(width, height) {
            var screenAvail = kicker.availableScreenRect;
            var screen = kicker.screenGeometry;
            var panelH = screen.height - screenAvail.height;
            var panelW = screen.width - screenAvail.width;
            var horizMidPoint = screen.x + (screen.width / 2);
            var vertMidPoint = screen.y + (screen.height / 2);
            var appletTopLeft = parent.mapToGlobal(0, 0);

            function calculatePosition(x, y) {
                return Qt.point(x, y);
            }

            if (menuPos === 0) {
                switch (plasmoid.location) {
                    case PlasmaCore.Types.BottomEdge:
                        var x = appletTopLeft.x < screen.width - width ? appletTopLeft.x : screen.width - width - 8;
                        var y = appletTopLeft.y - rootItem.height - backgroundSvg.margins.bottom - backgroundSvg.margins.top - Kirigami.Units.gridUnit
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.TopEdge:
                        x = appletTopLeft.x < screen.width - width ? appletTopLeft.x + panelW - Kirigami.Units.gridUnit / 3 : screen.width - width;
                        y = appletTopLeft.y + kicker.height + Kirigami.Units.gridUnit
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.LeftEdge:
                        x = appletTopLeft.x + panelW + Kirigami.Units.gridUnit / 2;
                        y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : appletTopLeft.y - height + iconUser.height / 2;
                        return calculatePosition(x, y);

                    case PlasmaCore.Types.RightEdge:
                        x = appletTopLeft.x - width - Kirigami.Units.gridUnit / 2;
                        y = appletTopLeft.y < screen.height - height ? appletTopLeft.y : screen.height - height - Kirigami.Units.gridUnit / 5;
                        return calculatePosition(x, y);

                    default:
                        return;
                }
            } else if (menuPos === 2) {
                x = horizMidPoint - width / 2;
                y = screen.height - height - panelH - Kirigami.Units.gridUnit / 2;
                return calculatePosition(x, y);
            } else if (menuPos === 1) {
                x = horizMidPoint - width / 2;
                y = vertMidPoint - height / 2;
                return calculatePosition(x, y);
            }
        }

        FocusScope {
            id: rootItem
            Layout.minimumWidth:  Kirigami.Units.gridUnit*36
            Layout.maximumWidth:  minimumWidth
            Layout.minimumHeight: Kirigami.Units.gridUnit*30
            Layout.maximumHeight: Kirigami.Units.gridUnit*30
            focus: true


            KCoreAddons.KUser {   id: kuser  }
            Logic { id: logic }


            OpacityAnimator { id: animation1; target: rootItem; from: 0; to: 1; easing.type: Easing.InOutQuad;  }

            Sessions.SessionManagement {
                id: sm
            }

            P5Support.DataSource {
                id: executable
                engine: "executable"
                connectedSources: []
                onNewData: {
                    var exitCode = data["exit code"]
                    var exitStatus = data["exit status"]
                    var stdout = data["stdout"]
                    var stderr = data["stderr"]
                    exited(sourceName, exitCode, exitStatus, stdout, stderr)
                    disconnectSource(sourceName)
                }
                function exec(cmd) {
                    if (cmd) {
                        connectSource(cmd)
                    }
                }
                signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
            }

            PlasmaExtras.Highlight  {
                id: delegateHighlight
                visible: false
                z: -1 // otherwise it shows ontop of the icon/label and tints them slightly
            }

            Kirigami.Heading {
                id: dummyHeading
                visible: false
                width: 0
                level: 5
            }

            TextMetrics {
                id: headingMetrics
                font: dummyHeading.font
            }

            KSvg.FrameSvgItem {
                id : headingSvg
                width: parent.width + backgroundSvg.margins.left + backgroundSvg.margins.right
                //height:  root.cellSizeHeight * Plasmoid.configuration.numberRows  + Kirigami.Units.gridUnit * 2 + backgroundSvg.margins.bottom - 1 //<>+ paginationBar.height
                height: 85
                y: - backgroundSvg.margins.top
                x: - backgroundSvg.margins.left
                imagePath: "widgets/plasmoidheading"
                prefix: "header"
                opacity: 0.6
            }




            RowLayout {
                id: tab
                height: 32
                spacing: 24
                anchors {
                    top: headingSvg.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                property int activeTab: 1
                property int textsize: 14

                Column {
                    id: pinnedColumn
                    width: pinned.implicitWidth
                    height: parent.height
                    MouseArea {
                        width: pinned.implicitWidth
                        height: parent.height
                        anchors.centerIn: pinnedColumn
                        onClicked: {
                           tab.activeTab = 1
                        }
                    }
                    Rectangle {
                        id: pinnedRectangle
                        width: parent.width
                        height: 6
                        radius: height/2
                        color: tab.activeTab === 1 ? Kirigami.Theme.highlightColor : "transparent"
                    }
                    Text {
                        id: pinned
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: parent.height - 6
                        text: i18n("Pinned")
                        font.pixelSize: tab.textsize
                        color: Kirigami.Theme.textColor
                    }

                }
                Column {
                    id: allAppsColumn
                    width: allApps.implicitWidth
                    height: parent.height
                    MouseArea {
                        width: allApps.implicitWidth
                        height: parent.height
                        anchors.centerIn: allAppsColumn
                        onClicked: {
                            tab.activeTab = 2
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 6
                        radius: height/2
                        color: tab.activeTab === 2 ? Kirigami.Theme.highlightColor : "transparent"
                    }
                    Text {
                        anchors.bottom: parent.bottom
                        id: allApps
                        width: parent.width
                        height: parent.height - 6
                        text: i18n("All Apps")
                        font.pixelSize: tab.textsize
                        color: Kirigami.Theme.textColor
                    }
                }
                Column {
                    id: searchColumn
                    width: rowSearch.width
                    height: parent.height
                    Rectangle {
                        id: allAppsRectangle
                        width: parent.width
                        height: 6
                        radius: height/2
                        color: tab.activeTab === 3 ? Kirigami.Theme.highlightColor : "transparent"
                    }
                    Row {
                        anchors.top: allAppsRectangle.bottom
                        id: rowSearch
                        width: search.implicitWidth + 25
                        height: parent.height - allAppsRectangle.height
                        spacing: 3
                        Kirigami.Icon {
                            source:  "search"
                            width: 22
                            height: 22

                        }
                        Text {
                            id: search
                            width: parent.width
                            height: parent.height
                            text: i18n("Search")
                            font.pixelSize: tab.textsize
                            color: Kirigami.Theme.textColor
                        }
                    }

                    MouseArea {
                        width: parent.width
                        height: parent.height
                        anchors.centerIn: searchColumn
                        onClicked: {
                            tab.activeTab = 3
                        }
                    }
                }
            }
            Item {
                id: actionsToolbar
                width: viewActionsToolbar.width
                height: 24
                anchors.verticalCenter: headingSvg.verticalCenter
                anchors.right: headingSvg.right
                anchors.rightMargin: height

                ListModel {
                    id: toolbarModel
                    ListElement {
                        icon: "system-shutdown"
                        command: "pmEngine.performOperation('requestShutDown')"
                    }
                    ListElement {
                        icon: "configure"
                        command: "systemsettings"
                    }
                    ListElement {
                        icon: "user-home-symbolic"
                        command: "xdg-open $HOME"
                    }
                }

                ListView {
                    id: viewActionsToolbar
                    width: toolbarModel.count * 24 + (toolbarModel.count - 1) * 5
                    height: 24
                    model: toolbarModel
                    orientation: Qt.Horizontal
                    spacing: 5

                    delegate: Item {
                        width: 24
                        height: 24

                        Kirigami.Icon {
                            id: icon
                            source: model.icon
                            width: height
                            isMask: true
                            roundToIconSize: false
                            //visible: false
                            height: 24
                            color: Kirigami.Theme.textColor

                        }

                        MouseArea {
                            width: parent.width
                            height: parent.height
                            anchors.centerIn: parent
                            onClicked: {
                                if (model.command === "pmEngine.performOperation('requestShutDown')") {
                                    sm.requestLogoutPrompt()
                                } else {
                                    executable.exec(model.command);
                                }
                            }
                        }
                        //Component.onCompleted: {
                          //  console.log("pruebassss",icon.paintedHeight, fakeIcon.implicitHeight, icon.paintedWidth)
                            //var factor = ""
                            //factor = 24/icon.implicitHeight
                            //icon.height = icon.height * factor
                        //}
                    }

                }
            }

            Item {
                id:  wrapperAvatar
                height: 48
                width: height
                anchors.verticalCenter: headingSvg.verticalCenter
                anchors.left: headingSvg.left
                anchors.leftMargin: height/2
                Rectangle {
                    id: maskavatar
                    height: parent.height
                    width: height
                    radius: height/2
                    visible: false
                }
                Image {
                    id: avatar
                    source: kuser.faceIconUrl
                    height: parent.height
                    width: height
                    anchors.horizontalCenter: parent.horizontalCenter
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: maskavatar
                    }
                }
                Rectangle {
                    id: outline
                    height: parent.height
                    width: height
                    radius: height/2
                    border.width: 1
                    border.color: Kirigami.Theme.TextColor
                    opacity: 0.2
                }
            }
            Item {
                width: textuser.implicitWidth
                height: textuser.implicitHeight
                visible: true
                anchors.verticalCenter: headingSvg.verticalCenter
                anchors.topMargin: iconUser.height/2 + Kirigami.Units.gridUnit * .5
                anchors.left: parent.left
                anchors.leftMargin: wrapperAvatar.width + wrapperAvatar.height/2 + Kirigami.Units.gridUnit/2

                Text {
                    width: parent.width
                    height: parent.height
                    id: textuser
                    text: kuser.fullName
                    font.pixelSize: 17
                    font.capitalization: Font.Capitalize
                    color: Kirigami.Theme.textColor
                }
            }
            //
            //
            //
            //
            //
            RowLayout {
                id: rowSearchField
                width: parent.width*.4
                visible: tab.activeTab === 3
                anchors{
                    top: tab.bottom
                    horizontalCenter: parent.horizontalCenter
                }


                PC3.TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: i18n("Type here to search ...")
                    topPadding: 10
                    bottomPadding: 10
                    leftPadding: ((parent.width - width)/2) + Kirigami.Units.iconSizes.small*2
                    text: ""
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                    onTextChanged: {
                        runnerModel.query = text;
                    }

                    Keys.onPressed: (event)=> {
                                        if (event.key === Qt.Key_Escape) {
                                            event.accepted = true;
                                            if(root.searching){
                                                searchField.clear()
                                            } else {
                                                root.toggle()
                                            }
                                        }

                                        if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                                            event.accepted = true;
                                            if(root.showFavorites)
                                            globalFavoritesGrid.tryActivate(0,0)
                                            else
                                            mainColumn.visibleGrid.tryActivate(0,0)
                                        }
                                    }

                    function backspace() {
                        if (!root.visible) {
                            return;
                        }
                        focus = true;
                        text = text.slice(0, -1);
                    }

                    function appendText(newText) {
                        if (!root.visible) {
                            return;
                        }
                        focus = true;
                        text = text + newText;
                    }
                    Kirigami.Icon {
                        source: 'search'
                        anchors {
                            left: searchField.left
                            verticalCenter: searchField.verticalCenter
                            leftMargin: Kirigami.Units.smallSpacing * 2

                        }
                        height: Kirigami.Units.iconSizes.small
                        width: height
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

            }

            //
            //
            //
            //
            //

            ItemGridView {
                id: globalFavoritesGrid
                visible: tab.activeTab === 1
                anchors {
                    top: tab.bottom
                    //topMargin: Kirigami.Units.gridUnit * 3
                }

                dragEnabled: true
                dropEnabled: true
                width: root.width
                height: root.height - headingSvg.height - tab.height - Kirigami.Units.gridUnit
                focus: true
                cellWidth:   126
                cellHeight:  134
                iconSize:    64
                onKeyNavUp: searchField.focus = true
                Keys.onPressed:(event)=> {
                                   if(event.modifiers & Qt.ControlModifier ||event.modifiers & Qt.ShiftModifier){
                                       searchField.focus = true;
                                       return
                                   }
                                   if (event.key === Qt.Key_Tab) {
                                       event.accepted = true;
                                       searchField.focus = true
                                   }
                               }
            }


            Item{
                id: mainGrids
                visible: !globalFavoritesGrid.visible

                anchors {
                    top: tab.activeTab === 3 ? rowSearchField.bottom : tab.bottom
                    //topMargin: Kirigami.Units.gridUnit /2
                    //left: parent.left
                    //right: parent.right

                }

                width: 126
                height: 134

                Item {
                    id: mainColumn
                    //width: root.cellSize *  Plasmoid.configuration.numberColumns + Kirigami.Units.gridUnit
                    width: rootItem.width
                    height: root.cellSizeHeight * Plasmoid.configuration.numberRows

                    property Item visibleGrid: allAppsGrid

                    function tryActivate(row, col) {
                        if (visibleGrid) {
                            visibleGrid.tryActivate(row, col);
                        }
                    }

                    ItemGridView {
                        id: allAppsGrid

                        //width: root.cellSize *  Plasmoid.configuration.numberColumns + Kirigami.Units.gridUnit
                        width: root.width
                        Layout.maximumWidth: rootItem.width*.6
                        height: tab.activeTab === 3 ? root.height - headingSvg.height - tab.height - rowSearchField.height -Kirigami.Units.gridUnit : root.height - headingSvg.height - tab.height - Kirigami.Units.gridUnit
                        cellWidth:   126
                        cellHeight:  134
                        iconSize:    64
                        enabled: (opacity == 1) ? 1 : 0
                        z:  enabled ? 5 : -1
                        dropEnabled: false
                        dragEnabled: false
                        opacity: root.searching ? 0 : 1
                        onOpacityChanged: {
                            if (opacity == 1) {
                                //allAppsGrid.scrollBar.flickableItem.contentY = 0;
                                mainColumn.visibleGrid = allAppsGrid;
                            }
                        }
                        onKeyNavUp: searchField.focus = true
                    }

                    ItemMultiGridView {
                        id: runnerGrid
                        width: root.width
                        height: root.height - headingSvg.height - tab.height - rowSearchField.height -Kirigami.Units.gridUnit
                        cellWidth:   126
                        cellHeight:  134
                        enabled: (opacity == 1.0) ? 1 : 0
                        z:  enabled ? 5 : -1
                        model: runnerModel
                        grabFocus: true
                        opacity: root.searching ? 1.0 : 0.0
                        onOpacityChanged: {
                            if (opacity == 1.0) {
                                mainColumn.visibleGrid = runnerGrid;
                            }
                        }
                        onKeyNavUp: searchField.focus = true
                    }

                    Keys.onPressed: (event)=> {
                                        if(event.modifiers & Qt.ControlModifier ||event.modifiers & Qt.ShiftModifier){
                                            searchField.focus = true;
                                            return
                                        }
                                        if (event.key === Qt.Key_Tab) {
                                            event.accepted = true;
                                            searchField.focus = true
                                        } else if (event.key === Qt.Key_Backspace) {
                                            event.accepted = true;
                                            if(root.searching)
                                            searchField.backspace();
                                            else
                                            searchField.focus = true
                                        } else if (event.key === Qt.Key_Escape) {
                                            event.accepted = true;
                                            if(root.searching){
                                                searchField.clear()
                                            } else {
                                                root.toggle()
                                            }
                                        } else if (event.text !== "") {
                                            event.accepted = true;
                                            searchField.appendText(event.text);
                                        }
                                    }
                }
            }




            Keys.onPressed: (event)=> {
                                if(event.modifiers & Qt.ControlModifier ||event.modifiers & Qt.ShiftModifier){
                                    searchField.focus = true;
                                    return
                                }
                                if (event.key === Qt.Key_Escape) {
                                    event.accepted = true;
                                    if (root.searching) {
                                        reset();
                                    } else {
                                        root.visible = false;
                                    }
                                    return;
                                }

                                if (searchField.focus) {
                                    return;
                                }

                                if (event.key === Qt.Key_Backspace) {
                                    event.accepted = true;
                                    searchField.backspace();
                                }  else if (event.text !== "") {
                                    event.accepted = true;
                                    searchField.appendText(event.text);
                                }
                            }

        }

        function setModels(){
            globalFavoritesGrid.model = globalFavorites
            allAppsGrid.model = rootModel.modelForRow(0);
        }

        Component.onCompleted: {
            rootModel.refreshed.connect(setModels)
            reset();
            rootModel.refresh();
            if (Plasmoid.configuration.showFavoritesFirst) {
                tab.active = 1
            } else {
                tab.active = 2
            }
        }
    }
    onObserverTabChanged: {
        searchField.text = "";  // Vacía el TextField al cambiar x
    }

}
