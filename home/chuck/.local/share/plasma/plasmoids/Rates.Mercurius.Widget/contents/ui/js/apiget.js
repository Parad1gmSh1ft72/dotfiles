function getExchangeRate(fromCurrency, toCurrency, callback) {
    var req = new XMLHttpRequest();
    var url = "https://cdn.dinero.today/api/latest.json";

    req.open("GET", url);

    req.onreadystatechange = function () {
        if (req.readyState == 4) {
            if (req.status == 200) {
                var data = JSON.parse(req.responseText);
                var fromRate = data.rates[fromCurrency];
                var toRate = data.rates[toCurrency];
                var exchangeRate = toRate / fromRate;
                console.log(`La tasa de cambio de ${fromCurrency} a ${toCurrency} es: ${exchangeRate}`);
                callback(exchangeRate);
            } else {
                console.error(`Error en la solicitud: ${req.status}`);
                callback(0)
            }
        }
    };

    req.send();
}


