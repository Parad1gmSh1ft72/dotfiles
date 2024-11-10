/*
    SPDX-FileCopyrightText: 2013-2014 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
    id: root

    readonly property bool vertical: (Plasmoid.formFactor === PlasmaCore.Types.Vertical)
    readonly property bool useCustomButtonImage: (Plasmoid.configuration.useCustomButtonImage
        && Plasmoid.configuration.customButtonImage.length !== 0)

    readonly property Component dashWindowComponent: kicker.isDash ? Qt.createComponent(Qt.resolvedUrl("./DashboardRepresentation.qml"), root) : null
    readonly property Kicker.DashboardWindow dashWindow: dashWindowComponent && dashWindowComponent.status === Component.Ready
        ? dashWindowComponent.createObject(root, { visualParent: root }) : null

    onWidthChanged: updateSizeHints()
    onHeightChanged: updateSizeHints()

    function updateSizeHints() {
        if (useCustomButtonImage) {
            if (vertical) {
                const scaledHeight = Math.floor(parent.width * (buttonIcon.implicitHeight / buttonIcon.implicitWidth));
                root.Layout.minimumWidth = -1;
                root.Layout.minimumHeight = scaledHeight;
                root.Layout.maximumWidth = Kirigami.Units.iconSizes.huge;
                root.Layout.maximumHeight = scaledHeight;
            } else {
                const scaledWidth = Math.floor(parent.height * (buttonIcon.implicitWidth / buttonIcon.implicitHeight));
                root.Layout.minimumWidth = scaledWidth;
                root.Layout.minimumHeight = -1;
                root.Layout.maximumWidth = scaledWidth;
                root.Layout.maximumHeight = Kirigami.Units.iconSizes.huge;
            }
        } else {
            root.Layout.minimumWidth = Kirigami.Units.iconSizes.huge;
            root.Layout.minimumHeight = Kirigami.Units.iconSizes.huge;
        }
    }

    Kirigami.Icon {
        id: buttonIcon

        anchors.fill: parent

        readonly property double aspectRatio: root.vertical
            ? implicitHeight / implicitWidth
            : implicitWidth / implicitHeight

        active: mouseArea.containsMouse && !justOpenedTimer.running
        source: root.useCustomButtonImage ? Plasmoid.configuration.customButtonImage : Plasmoid.configuration.icon

        // A custom icon could also be rectangular. However, if a square, custom, icon is given, assume it
        // to be an icon and round it to the nearest icon size again to avoid scaling artifacts.
        roundToIconSize: !root.useCustomButtonImage || aspectRatio === 1

        onSourceChanged: root.updateSizeHints()
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        property bool wasExpanded: false;

        activeFocusOnTab: true
        hoverEnabled: !root.dashWindow || !root.dashWindow.visible

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Space:
            case Qt.Key_Enter:
            case Qt.Key_Return:
            case Qt.Key_Select:
                Plasmoid.activated();
                break;
            }
        }
        Accessible.name: Plasmoid.title
        Accessible.description: toolTipSubText
        Accessible.role: Accessible.Button

        onPressed: {
            if (!kicker.isDash) {
                wasExpanded = kicker.expanded
            }
        }

        onClicked: {
            if (kicker.isDash) {
                root.dashWindow.toggle();
                justOpenedTimer.start();
            } else {
                kicker.expanded = !wasExpanded;
            }
        }
    }

    Connections {
        target: Plasmoid
        enabled: kicker.isDash && root.dashWindow !== null

        function onActivated() {
            root.dashWindow.toggle();
            justOpenedTimer.start();
        }
    }
}
