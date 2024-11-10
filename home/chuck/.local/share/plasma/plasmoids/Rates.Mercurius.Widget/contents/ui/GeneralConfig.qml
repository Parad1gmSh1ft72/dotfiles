import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: root


    signal configurationChanged

    QtObject {
        id: toCurrency
        property var value
    }

    QtObject {
        id: fromCurrency
        property var value
    }

    property alias cfg_toCurrencyConfig: toCurrency.value
    property alias cfg_boldFontConfig: boldTextCkeck.checked
    property alias cfg_fontSizeConfig: fontsizedefault.value
    property alias cfg_fromCurrencyConfig: fromCurrency.value
    ColumnLayout {
    id:mainColumn
    spacing: Kirigami.Units.largeSpacing
    Layout.fillWidth: true

    GridLayout{
        columns: 2

        Label {
            id: refrestitle
            Layout.minimumWidth: root.width/2
            text: i18n("Font Size:")
            horizontalAlignment: Label.AlignRight
        }
        SpinBox {
            from: 5
            id: fontsizedefault
            to: 40
        }
        Label {
        }
        Label {
        }
        Label {
            Layout.minimumWidth: root.width/2
            text: i18n("Bold:")
            horizontalAlignment: Label.AlignRight
        }

        CheckBox{
            id: boldTextCkeck
            text: i18n("")
        }
        Label {
        }
        Label {
        }
        Label {
            Layout.minimumWidth: root.width/2
            text: i18n("From Currency:")
            horizontalAlignment: Label.AlignRight
        }
        ComboBox {
            textRole: "text"
            valueRole: "value"
            id: nameFromCurrency
            model: [
                {text: i18n("USD"), value: 0},
                {text: i18n("JPY"), value: 1},
                {text: i18n("BGN"), value: 2},
                {text: i18n("CZK"), value: 3},
                {text: i18n("DKK"), value: 4},
                {text: i18n("GBP"), value: 5},
                {text: i18n("HUF"), value: 6},
                {text: i18n("PLN"), value: 7},
                {text: i18n("RON"), value: 8},
                {text: i18n("SEK"), value: 9},
                {text: i18n("CHF"), value: 10},
                {text: i18n("ISK"), value: 11},
                {text: i18n("NOK"), value: 12},
                {text: i18n("TRY"), value: 13},
                {text: i18n("AUD"), value: 14},
                {text: i18n("BRL"), value: 15},
                {text: i18n("CAD"), value: 16},
                {text: i18n("CNY"), value: 17},
                {text: i18n("HKD"), value: 18},
                {text: i18n("IDR"), value: 19},
                {text: i18n("ILS"), value: 20},
                {text: i18n("INR"), value: 21},
                {text: i18n("KRW"), value: 22},
                {text: i18n("MXN"), value: 23},
                {text: i18n("MYR"), value: 24},
                {text: i18n("NZD"), value: 25},
                {text: i18n("PHP"), value: 26},
                {text: i18n("SGD"), value: 27},
                {text: i18n("THB"), value: 28},
                {text: i18n("ZAR"), value: 29},
                {text: i18n("EUR"), value: 30}
            ]
            onActivated: fromCurrency.value = currentValue
            Component.onCompleted: currentIndex = indexOfValue(fromCurrency.value)
        }

        Label {
            Layout.minimumWidth: root.width/2
            text: i18n("To Currency:")
            horizontalAlignment: Label.AlignRight
        }
        ComboBox {
            textRole: "text"
            valueRole: "value"
            id: nameToCurrency
            model: [
                {text: i18n("USD"), value: 0},
                {text: i18n("JPY"), value: 1},
                {text: i18n("BGN"), value: 2},
                {text: i18n("CZK"), value: 3},
                {text: i18n("DKK"), value: 4},
                {text: i18n("GBP"), value: 5},
                {text: i18n("HUF"), value: 6},
                {text: i18n("PLN"), value: 7},
                {text: i18n("RON"), value: 8},
                {text: i18n("SEK"), value: 9},
                {text: i18n("CHF"), value: 10},
                {text: i18n("ISK"), value: 11},
                {text: i18n("NOK"), value: 12},
                {text: i18n("TRY"), value: 13},
                {text: i18n("AUD"), value: 14},
                {text: i18n("BRL"), value: 15},
                {text: i18n("CAD"), value: 16},
                {text: i18n("CNY"), value: 17},
                {text: i18n("HKD"), value: 18},
                {text: i18n("IDR"), value: 19},
                {text: i18n("ILS"), value: 20},
                {text: i18n("INR"), value: 21},
                {text: i18n("KRW"), value: 22},
                {text: i18n("MXN"), value: 23},
                {text: i18n("MYR"), value: 24},
                {text: i18n("NZD"), value: 25},
                {text: i18n("PHP"), value: 26},
                {text: i18n("SGD"), value: 27},
                {text: i18n("THB"), value: 28},
                {text: i18n("ZAR"), value: 29},
                {text: i18n("EUR"), value: 30}
            ]
            onActivated: toCurrency.value = currentValue
            Component.onCompleted: currentIndex = indexOfValue(toCurrency.value)
        }
    }
    }
}
