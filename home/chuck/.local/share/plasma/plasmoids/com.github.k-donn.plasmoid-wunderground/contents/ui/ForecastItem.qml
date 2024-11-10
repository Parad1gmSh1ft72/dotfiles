/*
 * Copyright 2024  Kevin Donnelly
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "../code/utils.js" as Utils

RowLayout {
    id: forecastItemRoot

    readonly property int preferredIconSize: Kirigami.Units.iconSizes.large

    Repeater {
        id: forecastRepeater

        model: forecastModel
        ColumnLayout {
            Layout.maximumWidth: parent.width / 7

            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignCenter

                text: date
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignCenter

                text: dayOfWeek
            }
            PlasmaComponents.Label {
                Layout.fillWidth: true

                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter

                text: shortDesc
            }
            Kirigami.Icon {
                id: icon

                Layout.alignment: Qt.AlignCenter

                Layout.preferredHeight: preferredIconSize
                Layout.preferredWidth: preferredIconSize

                source: Utils.getConditionIcon(iconCode)

                isMask: true
                color: Kirigami.Theme.textColor

                PlasmaCore.ToolTipArea {
                    id: tooltip

                    mainText: longDesc
                    subText: i18nc("Do not edit HTML tags.", "<font size='4'>Feels like: %1<br/>Thunder: %2<br/>UV: %3<br/>Snow: %4<br/>Golf: %5</font>", Utils.currentTempUnit(Utils.toUserTemp(feelsLike)), thunderDesc, uvDesc, snowDesc, golfDesc)

                    interactive: true

                    anchors.fill: parent
                }
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignCenter

                text: Utils.currentTempUnit(Utils.toUserTemp(high))
            }
            PlasmaComponents.Label {
                Layout.alignment: Qt.AlignCenter

                text: Utils.currentTempUnit(Utils.toUserTemp(low))
            }
        }
    }
}
