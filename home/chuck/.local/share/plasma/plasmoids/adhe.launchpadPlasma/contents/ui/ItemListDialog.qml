/*
    SPDX-FileCopyrightText: 2013-2014 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami

import org.kde.plasma.private.kicker 0.1 as Kicker

Kicker.SubMenu {
    id: itemDialog

    property alias focusParent: itemListView.focusParent
    property alias model: funnelModel.sourceModel

    property bool aboutToBeDestroyed: false

    visible: false
    hideOnWindowDeactivate: kicker.hideOnWindowDeactivate
    location: PlasmaCore.Types.Floating
    offset: Kirigami.Units.smallSpacing

    onWindowDeactivated: {
        if (!aboutToBeDestroyed) {
            kicker.expanded = false;
        }
    }

    mainItem: ItemListView {
        id: itemListView

        height: {
            const m = funnelModel.sourceModel;

            if (m === null || m === undefined) {
                // TODO: setting height to 0 triggers a warning in PlasmaQuick::Dialog
                return 0;
            }

            return Math.min(
                // either fit in screen boundaries (cut to the nearest item/separator boundary), ...
                __subFloorMultipleOf(
                    itemDialog.availableScreenRectForItem(itemListView).height
                    - itemDialog.margins.top
                    - itemDialog.margins.bottom,
                    itemHeight
                ) + m.separatorCount * (separatorHeight - itemHeight)
                ,
                // ...or fit the content itself -- whichever is shorter.
                ((m.count - m.separatorCount) * itemHeight)
                + (m.separatorCount * separatorHeight)
            );
        }

        // get x rounded down to the multiple of y, minus extra y.
        function __subFloorMultipleOf(x : real, y : real) : real {
            return (Math.floor(x / y) - 1) * y;
        }

        iconsEnabled: true

        dialog: itemDialog

        model: funnelModel

        Kicker.FunnelModel {
            id: funnelModel

            property bool sorted: sourceModel?.sorted ?? false

            Component.onCompleted: {
                kicker.reset.connect(funnelModel.reset);
            }

            onCountChanged: {
                if (sourceModel && count === 0) {
                    itemDialog.delayedDestroy();
                }
            }

            onSourceModelChanged: {
                itemListView.currentIndex = -1;
            }
        }
    }

    function delayedDestroy() {
        aboutToBeDestroyed = true;
        Plasmoid.hideOnWindowDeactivate = false;
        visible = false;

        Qt.callLater(() => itemDialog.destroy());
    }
}
