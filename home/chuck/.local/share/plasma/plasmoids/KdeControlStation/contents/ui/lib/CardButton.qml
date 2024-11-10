import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Card {
    id: cardButton
    signal clicked
    default property alias content: icon.data
    property alias title: title.text

    GridLayout {
        anchors.fill: parent
        property bool small: width < root.fullRepWidth/3
        anchors.margins: small ? root.smallSpacing : root.largeSpacing
        rows: small ? 2 : 1
        columns: small ? 1 : 2
        columnSpacing: small ? 0 : 10*root.scale
        rowSpacing: small ? 0 : 10*root.scale

        Item {
            id: icon
            Layout.preferredHeight: parent.small ? parent.height/1.3-root.smallSpacing: parent.height - root.largeSpacing
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }
        PlasmaComponents.Label {
            id: title
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: root.smallSpacing
            font.pixelSize: parent.small ? root.smallFontSize : root.mediumFontSize
            font.weight:Font.Bold
            horizontalAlignment: parent.small ? Qt.AlignHCenter : Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            cardButton.clicked()
        }
    }
}
