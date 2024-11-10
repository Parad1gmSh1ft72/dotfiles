/*
 * SPDX-FileCopyrightText: zayronxio
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "js/apiget.js" as ApiGET

RowLayout {
    id: wrapper
    property int pixelFontVar: Plasmoid.configuration.fontSizeConfig
    Layout.minimumWidth: fulltext.implicitWidth + pixelFontVar*4
    Layout.minimumHeight: heightroot

    property int heightroot: 20

    property int fromCurrencyConfig: Plasmoid.configuration.fromCurrencyConfig
    property int toCurrencyConfig: Plasmoid.configuration.toCurrencyConfig

    property string fromCurrency: nameCurrencySelected(fromCurrencyConfig)
    property string toCurrency: nameCurrencySelected(toCurrencyConfig)
    property bool datosverificado: false
    property real exchangeRate: 0 // Tasa de cambio

    function nameCurrencySelected(x) {
        let currencies = {
            0: "USD",
            1: "JPY",
            2: "BGN",
            3: "CZK",
            4: "DKK",
            5: "GBP",
            6: "HUF",
            7: "PLN",
            8: "RON",
            9: "SEK",
            10: "CHF",
            11: "ISK",
            12: "NOK",
            13: "TRY",
            14: "AUD",
            15: "BRL",
            16: "CAD",
            17: "CNY",
            18: "HKD",
            19: "IDR",
            20: "ILS",
            21: "INR",
            22: "KRW",
            23: "MXN",
            24: "MYR",
            25: "NZD",
            26: "PHP",
            27: "SGD",
            28: "THB",
            29: "ZAR",
            30: "EUR"
        };
        return currencies[x];
    }

    Component.onCompleted: {
        updateExchangeRate();
    }

    onFromCurrencyChanged: updateExchangeRate()
    onToCurrencyChanged: updateExchangeRate()

    function updateExchangeRate() {
        ApiGET.getExchangeRate(fromCurrency, toCurrency, function(result) {
            exchangeRate = result;
            retry.start();
        });
    }

    Timer {
        id: retry
        interval: 5000
        running: false
        repeat: false
        onTriggered: {
            if(exchangeRate === 0) {
                updateExchangeRate()
            } else {
                datosverificado = true
            }
        }
    }

    Text {
        id: fulltext
        height: parent.height
        width: wrapper.width
        font.pixelSize: pixelFontVar
        color: Kirigami.Theme.textColor
        font.bold: Plasmoid.configuration.boldFontConfig
        text: fromCurrency + "/" + toCurrency + " " + (datosverificado ? exchangeRate.toFixed(2) : "?")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Timer {
        id: timer
        interval: 3.6e+6
        running: true
        repeat: true
        onTriggered: {
           updateExchangeRate()
        }
    }
}
