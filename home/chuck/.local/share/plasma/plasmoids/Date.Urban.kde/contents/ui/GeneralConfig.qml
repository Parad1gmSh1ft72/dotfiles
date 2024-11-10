import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: configRoot

    signal configurationChanged

    property alias cfg_colordaytext: colordaytext.text
    property alias cfg_colordatetext: colordatetext.text

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        Layout.fillWidth: true
        GridLayout {
            columns: 2
            Label {
                text: "Color day text"
                Layout.minimumWidth: configRoot.width/2
                horizontalAlignment: Label.AlignRight
            }
            TextField {
                id: colordaytext
                width: 200
            }
            Label {

            }
            Label {

            }
            Label {
                text: "Color date text"
                Layout.minimumWidth: configRoot.width/2
                horizontalAlignment: Label.AlignRight
            }
            TextField {
                id: colordatetext
                width: 200
            }
        }

}

}
