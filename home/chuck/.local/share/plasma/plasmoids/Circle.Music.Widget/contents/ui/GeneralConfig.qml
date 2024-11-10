import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    signal configurationChanged

    property alias cfg_colorGeneral: color.text

    ColumnLayout {
        spacing: units.smallSpacing * 2
        GridLayout{
            columns: 2
            Label {
                Layout.minimumWidth: configRoot.width/2
                text: i18n("Color:")
                horizontalAlignment: Label.AlignRight
            }
            TextField {
                id: color
                width: 150
            }
        }
    }
}
