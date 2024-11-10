import QtQuick 2.12
import QtQuick.Controls 2.15
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import "js/Texts.js" as Texts

PlasmoidItem {
    id: root
    width: 450
    height: 150
    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    property color widgetColor: "white"
    property string codelang: ((Qt.locale().name)[0]+(Qt.locale().name)[1])

    FontLoader {
        id: klik
        source: "../fonts/Klik-Light.otf"
    }
    FontLoader {
        id: milestone
        source: "../fonts/MilestoneBrush.ttf"
    }

    fullRepresentation: Column {
        id: wrapper
        width: parent.width < parent.height*3 ? parent.width : parent.height*3
        height: width/3
        anchors.centerIn: parent
        Text {
            id: day
            width: parent.width
            height: parent.height*.7
            text: Texts.getDayWeekText(codelang, (new Date()).getDay())
            font.pixelSize: height*1.3
            color: widgetColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            topPadding: height*.7
            font.family: milestone.name
            font.capitalization: Font.Capitalize
        }
        Text {
            id: dayOfMonth
            width: parent.width
            height: parent.height*.15
            text: Texts.TextNumbers(codelang, Qt.formatDateTime(new Date(), "d"))
            font.pixelSize: height*1.1
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: klik.name
            color: widgetColor
            font.capitalization: Font.Capitalize
        }
        Text {
            id: month
            width: parent.width
            height: parent.height*.15
            text: Texts.getMonthText(codelang, Qt.formatDateTime(new Date(), "M")-1)
            font.pixelSize: height*1.1
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: klik.name
            font.capitalization: Font.Capitalize
            color: widgetColor
        }
        Timer {
            id: timer
            interval: 8.64e+7-((new Date().getHours()*60*60*1000)+(new Date().getMinutes()*60*1000)+(new Date().getSeconds()*1000)+new Date().getMilliseconds())
            running: true
            repeat: true
            onTriggered: {
                month.text = Texts.getMonthText(codelang, Qt.formatDateTime(new Date(), "M")-1)
                dayOfMonth.text = Texts.TextNumbers(codelang, Qt.formatDateTime(new Date(), "d"))
                day.text = Texts.getDayWeekText(codelang, (new Date()).getDay())
                timer.interval = 8.64e+7
            }
        }
    }
}
