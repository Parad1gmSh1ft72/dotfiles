import QtQuick 2.12
import QtQuick.Controls 2.15
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import "js/Texts.js" as Texts

PlasmoidItem {
    id: root
    width: 650
    height: 150
    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    FontLoader {
        id: windsong
        source: "../fonts/Arizonia-Regular.ttf"
    }
    FontLoader {
        id: pressuru
        source: "../fonts/pressuru.otf"
    }


    property int dayMonth: Qt.formatDateTime(new Date(), "d")
    property string codeleng: ((Qt.locale().name)[0]+(Qt.locale().name)[1])


    fullRepresentation: Item {
        Text {
            id: dayMonthTxt
            width: root.width
            height: root.height
            text: Texts.TextNumbers(codeleng, dayMonth)
            color: "white"
            font.capitalization: Font.AllUppercase
            font.pixelSize: root.height*.85
            font.bold: true
            font.family: pressuru.name
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            opacity: 0.35
            font.letterSpacing: 5
        }
        Text {
            id: dayWeek
            text: Texts.getDayWeekText(codeleng, (new Date()).getDay())
            color: "white"
            width: root.width
            height: root.height
            font.pixelSize: root.height*.7
            font.family: windsong.name
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    Timer {
        id: timerDate
        interval: 8.64e+7-((new Date().getHours()*60*60*1000)+(new Date().getMinutes()*60*1000)+(new Date().getSeconds()*1000)+new Date().getMilliseconds())
        running: true
        repeat: true
        onTriggered: {
            dayWeek.text = Texts.getDayWeekText(codeleng, (new Date()).getDay())
            dayMonth = Qt.formatDateTime(new Date(), "d")
            timerDate.interval = 8.64e+7-((new Date().getHours()*60*60*1000)+(new Date().getMinutes()*60*1000)+(new Date().getSeconds()*1000)+new Date().getMilliseconds())
        }
    }
}
