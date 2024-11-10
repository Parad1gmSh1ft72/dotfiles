function TextNumbers(languageCode, x) {
    let numbers = {
        en: {
            1: "one", 2: "two", 3: "three", 4: "four", 5: "five", 6: "six", 7: "seven", 8: "eight", 9: "nine", 10: "ten",
            11: "eleven", 12: "twelve", 13: "thirteen", 14: "fourteen", 15: "fifteen", 16: "sixteen", 17: "seventeen", 18: "eighteen", 19: "nineteen", 20: "twenty",
            21: "twenty-one", 22: "twenty-two", 23: "twenty-three", 24: "twenty-four", 25: "twenty-five", 26: "twenty-six", 27: "twenty-seven", 28: "twenty-eight", 29: "twenty-nine", 30: "thirty", 31: "thirty-one"
        },
        es: {
            1: "uno", 2: "dos", 3: "tres", 4: "cuatro", 5: "cinco", 6: "seis", 7: "siete", 8: "ocho", 9: "nueve", 10: "diez",
            11: "once", 12: "doce", 13: "trece", 14: "catorce", 15: "quince", 16: "dieciséis", 17: "diecisiete", 18: "dieciocho", 19: "diecinueve", 20: "veinte",
            21: "veintiuno", 22: "veintidós", 23: "veintitrés", 24: "veinticuatro", 25: "veinticinco", 26: "veintiséis", 27: "veintisiete", 28: "veintiocho", 29: "veintinueve", 30: "treinta", 31: "treinta y uno"
        },
        fr: {
            1: "un", 2: "deux", 3: "trois", 4: "quatre", 5: "cinq", 6: "six", 7: "sept", 8: "huit", 9: "neuf", 10: "dix",
            11: "onze", 12: "douze", 13: "treize", 14: "quatorze", 15: "quinze", 16: "seize", 17: "dix-sept", 18: "dix-huit", 19: "dix-neuf", 20: "vingt",
            21: "vingt et un", 22: "vingt-deux", 23: "vingt-trois", 24: "vingt-quatre", 25: "vingt-cinq", 26: "vingt-six", 27: "vingt-sept", 28: "vingt-huit", 29: "vingt-neuf", 30: "trente", 31: "trente et un"
        },
        it: {
            1: "uno", 2: "due", 3: "tre", 4: "quattro", 5: "cinque", 6: "sei", 7: "sette", 8: "otto", 9: "nove", 10: "dieci",
            11: "undici", 12: "dodici", 13: "tredici", 14: "quattordici", 15: "quindici", 16: "sedici", 17: "diciassette", 18: "diciotto", 19: "diciannove", 20: "venti",
            21: "ventuno", 22: "ventidue", 23: "ventitre", 24: "ventiquattro", 25: "venticinque", 26: "ventisei", 27: "ventisette", 28: "ventotto", 29: "ventinove", 30: "trenta", 31: "trentuno"
        },
        pt: {
            1: "um", 2: "dois", 3: "três", 4: "quatro", 5: "cinco", 6: "seis", 7: "sete", 8: "oito", 9: "nove", 10: "dez",
            11: "onze", 12: "doze", 13: "treze", 14: "catorze", 15: "quinze", 16: "dezesseis", 17: "dezessete", 18: "dezoito", 19: "dezenove", 20: "vinte",
            21: "vinte e um", 22: "vinte e dois", 23: "vinte e três", 24: "vinte e quatro", 25: "vinte e cinco", 26: "vinte e seis", 27: "vinte e sete", 28: "vinte e oito", 29: "vinte e nove", 30: "trinta", 31: "trinta e um"
        },
        de: {
            1: "eins", 2: "zwei", 3: "drei", 4: "vier", 5: "fünf", 6: "sechs", 7: "sieben", 8: "acht", 9: "neun", 10: "zehn",
            11: "elf", 12: "zwölf", 13: "dreizehn", 14: "vierzehn", 15: "fünfzehn", 16: "sechzehn", 17: "siebzehn", 18: "achtzehn", 19: "neunzehn", 20: "zwanzig",
            21: "einundzwanzig", 22: "zweiundzwanzig", 23: "dreiundzwanzig", 24: "vierundzwanzig", 25: "fünfundzwanzig", 26: "sechsundzwanzig", 27: "siebenundzwanzig", 28: "achtundzwanzig", 29: "neunundzwanzig", 30: "dreißig", 31: "einunddreißig"
        },
        nl: {
            1: "een", 2: "twee", 3: "drie", 4: "vier", 5: "vijf", 6: "zes", 7: "zeven", 8: "acht", 9: "negen", 10: "tien",
            11: "elf", 12: "twaalf", 13: "dertien", 14: "veertien", 15: "vijftien", 16: "zestien", 17: "zeventien", 18: "achttien", 19: "negentien", 20: "twintig",
            21: "eenentwintig", 22: "tweeëntwintig", 23: "drieëntwintig", 24: "vierentwintig", 25: "vijfentwintig", 26: "zesentwintig", 27: "zevenentwintig", 28: "achtentwintig", 29: "negenentwintig", 30: "dertig", 31: "eenendertig"
        },
        sv: {
            1: "ett", 2: "två", 3: "tre", 4: "fyra", 5: "fem", 6: "sex", 7: "sju", 8: "åtta", 9: "nio", 10: "tio",
            11: "elva", 12: "tolv", 13: "tretton", 14: "fjorton", 15: "femton", 16: "sexton", 17: "sjutton", 18: "arton", 19: "nitton", 20: "tjugo",
            21: "tjugoett", 22: "tjugotvå", 23: "tjugotre", 24: "tjugofyra", 25: "tjugofem", 26: "tjugosex", 27: "tjugosju", 28: "tjugoåtta", 29: "tjugonio", 30: "trettio", 31: "trettioett"
        },
        da: {
            1: "en", 2: "to", 3: "tre", 4: "fire", 5: "fem", 6: "seks", 7: "syv", 8: "otte", 9: "ni", 10: "ti",
            11: "elleve", 12: "tolv", 13: "tretten", 14: "fjorten", 15: "femten", 16: "seksten", 17: "sytten", 18: "atten", 19: "nitten", 20: "tyve",
            21: "enogtyve", 22: "toogtyve", 23: "treogtyve", 24: "fireogtyve", 25: "femogtyve", 26: "seksogtyve", 27: "syvogtyve", 28: "otteogtyve", 29: "niogtyve", 30: "tredive", 31: "enogtredive"
        },
        no: {
            1: "en", 2: "to", 3: "tre", 4: "fire", 5: "fem", 6: "seks", 7: "sju", 8: "åtte", 9: "ni", 10: "ti",
            11: "elleve", 12: "tolv", 13: "tretten", 14: "fjorten", 15: "femten", 16: "seksten", 17: "sytten", 18: "atten", 19: "nitten", 20: "tjue",
            21: "tjueen", 22: "tjueto", 23: "tjuetre", 24: "tjuefire", 25: "tjuefem", 26: "tjueseks", 27: "tjuesju", 28: "tjueåtte", 29: "tjueni", 30: "tretti", 31: "trettien"
        },
        fi: {
            1: "yksi", 2: "kaksi", 3: "kolme", 4: "neljä", 5: "viisi", 6: "kuusi", 7: "seitsemän", 8: "kahdeksan", 9: "yhdeksän", 10: "kymmenen",
            11: "yksitoista", 12: "kaksitoista", 13: "kolmetoista", 14: "neljätoista", 15: "viisitoista", 16: "kuusitoista", 17: "seitsemäntoista", 18: "kahdeksantoista", 19: "yhdeksäntoista", 20: "kaksikymmentä",
            21: "kaksikymmentäyksi", 22: "kaksikymmentäkaksi", 23: "kaksikymmentäkolme", 24: "kaksikymmentäneljä", 25: "kaksikymmentäviisi", 26: "kaksikymmentäkuusi", 27: "kaksikymmentäseitsemän", 28: "kaksikymmentäkahdeksan", 29: "kaksikymmentäyhdeksän", 30: "kolmekymmentä", 31: "kolmekymmentäyksi"
        },
        is: {
            1: "einn", 2: "tveir", 3: "þrír", 4: "fjórir", 5: "fimm", 6: "sex", 7: "sjö", 8: "átta", 9: "níu", 10: "tíu",
            11: "ellefu", 12: "tólf", 13: "þrettán", 14: "fjórtán", 15: "fimmtán", 16: "sextán", 17: "sautján", 18: "átján", 19: "nítján", 20: "tuttugu",
            21: "tuttugu og einn", 22: "tuttugu og tveir", 23: "tuttugu og þrír", 24: "tuttugu og fjórir", 25: "tuttugu og fimm", 26: "tuttugu og sex", 27: "tuttugu og sjö", 28: "tuttugu og átta", 29: "tuttugu og níu", 30: "þrjátíu", 31: "þrjátíu og einn"
        },
        pl: {
            1: "jeden", 2: "dwa", 3: "trzy", 4: "cztery", 5: "pięć", 6: "sześć", 7: "siedem", 8: "osiem", 9: "dziewięć", 10: "dziesięć",
            11: "jedenaście", 12: "dwanaście", 13: "trzynaście", 14: "czternaście", 15: "piętnaście", 16: "szesnaście", 17: "siedemnaście", 18: "osiemnaście", 19: "dziewiętnaście", 20: "dwadzieścia",
            21: "dwadzieścia jeden", 22: "dwadzieścia dwa", 23: "dwadzieścia trzy", 24: "dwadzieścia cztery", 25: "dwadzieścia pięć", 26: "dwadzieścia sześć", 27: "dwadzieścia siedem", 28: "dwadzieścia osiem", 29: "dwadzieścia dziewięć", 30: "trzydzieści", 31: "trzydzieści jeden"
        },
        ro: {
            1: "unu", 2: "doi", 3: "trei", 4: "patru", 5: "cinci", 6: "șase", 7: "șapte", 8: "opt", 9: "nouă", 10: "zece",
            11: "unsprezece", 12: "doisprezece", 13: "treisprezece", 14: "paisprezece", 15: "cincisprezece", 16: "șaisprezece", 17: "șaptesprezece", 18: "optsprezece", 19: "nouăsprezece", 20: "douăzeci",
            21: "douăzeci și unu", 22: "douăzeci și doi", 23: "douăzeci și trei", 24: "douăzeci și patru", 25: "douăzeci și cinci", 26: "douăzeci și șase", 27: "douăzeci și șapte", 28: "douăzeci și opt", 29: "douăzeci și nouă", 30: "treizeci", 31: "treizeci și unu"
        },
        cs: {
            1: "jeden", 2: "dva", 3: "tři", 4: "čtyři", 5: "pět", 6: "šest", 7: "sedm", 8: "osm", 9: "devět", 10: "deset",
            11: "jedenáct", 12: "dvanáct", 13: "třináct", 14: "čtrnáct", 15: "patnáct", 16: "šestnáct", 17: "sedmnáct", 18: "osmnáct", 19: "devatenáct", 20: "dvacet",
            21: "dvacet jedna", 22: "dvacet dva", 23: "dvacet tři", 24: "dvacet čtyři", 25: "dvacet pět", 26: "dvacet šest", 27: "dvacet sedm", 28: "dvacet osm", 29: "dvacet devět", 30: "třicet", 31: "třicet jedna"
        },
        sk: {
            1: "jeden", 2: "dva", 3: "tri", 4: "štyri", 5: "päť", 6: "šesť", 7: "sedem", 8: "osem", 9: "deväť", 10: "desať",
            11: "jedenásť", 12: "dvanásť", 13: "trinásť", 14: "štrnásť", 15: "pätnásť", 16: "šestnásť", 17: "sedemnásť", 18: "osemnásť", 19: "devätnásť", 20: "dvadsať",
            21: "dvadsaťjeden", 22: "dvadsaťdva", 23: "dvadsaťtri", 24: "dvadsaťštyri", 25: "dvadsaťpäť", 26: "dvadsaťšesť", 27: "dvadsaťsedem", 28: "dvadsaťosem", 29: "dvadsaťdeväť", 30: "tridsať", 31: "tridsaťjeden"
        },
        hu: {
            1: "egy", 2: "kettő", 3: "három", 4: "négy", 5: "öt", 6: "hat", 7: "hét", 8: "nyolc", 9: "kilenc", 10: "tíz",
            11: "tizenegy", 12: "tizenkettő", 13: "tizenhárom", 14: "tizennégy", 15: "tizenöt", 16: "tizenhat", 17: "tizenhét", 18: "tizennyolc", 19: "tizenkilenc", 20: "húsz",
            21: "huszonegy", 22: "huszonkettő", 23: "huszonhárom", 24: "huszonnégy", 25: "huszonöt", 26: "huszonhat", 27: "huszonhét", 28: "huszonnyolc", 29: "huszonkilenc", 30: "harminc", 31: "harmincegy"
        },
        hr: {
            1: "jedan", 2: "dva", 3: "tri", 4: "četiri", 5: "pet", 6: "šest", 7: "sedam", 8: "osam", 9: "devet", 10: "deset",
            11: "jedanaest", 12: "dvanaest", 13: "trinaest", 14: "četrnaest", 15: "petnaest", 16: "šesnaest", 17: "sedamnaest", 18: "osamnaest", 19: "devetnaest", 20: "dvadeset",
            21: "dvadeset jedan", 22: "dvadeset dva", 23: "dvadeset tri", 24: "dvadeset četiri", 25: "dvadeset pet", 26: "dvadeset šest", 27: "dvadeset sedam", 28: "dvadeset osam", 29: "dvadeset devet", 30: "trideset", 31: "trideset jedan"
        },
        sl: {
            1: "ena", 2: "dva", 3: "tri", 4: "štiri", 5: "pet", 6: "šest", 7: "sedem", 8: "osem", 9: "devet", 10: "deset",
            11: "enajst", 12: "dvanajst", 13: "trinajst", 14: "štirinajst", 15: "petnajst", 16: "šestnajst", 17: "sedemnajst", 18: "osemnajst", 19: "devetnajst", 20: "dvajset",
            21: "enaindvajset", 22: "dvaindvajset", 23: "triindvajset", 24: "štiriindvajset", 25: "petindvajset", 26: "šestindvajset", 27: "sedemindvajset", 28: "osemindvajset", 29: "devetindvajset", 30: "trideset", 31: "ena in trideset"
        },
        lt: {
            1: "vienas", 2: "du", 3: "trys", 4: "keturi", 5: "penki", 6: "šeši", 7: "septyni", 8: "aštuoni", 9: "devyni", 10: "dešimt",
            11: "vienuolika", 12: "dvylika", 13: "trylika", 14: "keturiolika", 15: "penkiolika", 16: "šešiolika", 17: "septyniolika", 18: "aštuoniolika", 19: "devyniolika", 20: "dvidešimt",
            21: "dvidešimt vienas", 22: "dvidešimt du", 23: "dvidešimt trys", 24: "dvidešimt keturi", 25: "dvidešimt penki", 26: "dvidešimt šeši", 27: "dvidešimt septyni", 28: "dvidešimt aštuoni", 29: "dvidešimt devyni", 30: "trisdešimt", 31: "trisdešimt vienas"
        },
        lv: {
            1: "viens", 2: "divi", 3: "trīs", 4: "četri", 5: "pieci", 6: "seši", 7: "septiņi", 8: "astoņi", 9: "deviņi", 10: "desmit",
            11: "vienpadsmit", 12: "divpadsmit", 13: "trīspadsmit", 14: "četrpadsmit", 15: "piecpadsmit", 16: "sešpadsmit", 17: "septiņpadsmit", 18: "astoņpadsmit", 19: "deviņpadsmit", 20: "divdesmit",
            21: "divdesmit viens", 22: "divdesmit divi", 23: "divdesmit trīs", 24: "divdesmit četri", 25: "divdesmit pieci", 26: "divdesmit seši", 27: "divdesmit septiņi", 28: "divdesmit astoņi", 29: "divdesmit deviņi", 30: "trīsdesmit", 31: "trīsdesmit viens"
        },
        et: {
            1: "üks", 2: "kaks", 3: "kolm", 4: "neli", 5: "viis", 6: "kuus", 7: "seitse", 8: "kaheksa", 9: "üheksa", 10: "kümme",
            11: "üksteist", 12: "kaksteist", 13: "kolmteist", 14: "neliteist", 15: "viisteist", 16: "kuusteist", 17: "seitseteist", 18: "kaheksateist", 19: "üheksateist", 20: "kakskümmend",
            21: "kakskümmend üks", 22: "kakskümmend kaks", 23: "kakskümmend kolm", 24: "kakskümmend neli", 25: "kakskümmend viis", 26: "kakskümmend kuus", 27: "kakskümmend seitse", 28: "kakskümmend kaheksa", 29: "kakskümmend üheksa", 30: "kolmkümmend", 31: "kolmkümmend üks"
        },
        sq: {
            1: "një", 2: "dy", 3: "tre", 4: "katër", 5: "pesë", 6: "gjashtë", 7: "shtatë", 8: "tetë", 9: "nëntë", 10: "dhjetë",
            11: "njëmbëdhjetë", 12: "dymbëdhjetë", 13: "trembëdhjetë", 14: "katërmbëdhjetë", 15: "pesëmbëdhjetë", 16: "gjashtëmbëdhjetë", 17: "shtatëmbëdhjetë", 18: "tetëmbëdhjetë", 19: "nëntëmbëdhjetë", 20: "njëzet",
            21: "njëzet e një", 22: "njëzet e dy", 23: "njëzet e tre", 24: "njëzet e katër", 25: "njëzet e pesë", 26: "njëzet e gjashtë", 27: "njëzet e shtatë", 28: "njëzet e tetë", 29: "njëzet e nëntë", 30: "tridhjetë", 31: "tridhjetë e një"
        },

    };

    return numbers[languageCode] ? numbers[languageCode][x] : numbers["en"][x]
}

function getDayWeekText(language, dayIndex) {
    const daysOfWeek = {
        es: ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"],
        en: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
        fr: ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"],
        it: ["Domenica", "Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato"],
        pt: ["Domingo", "Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado"],
        de: ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"],
        nl: ["Zondag", "Maandag", "Dinsdag", "Woensdag", "Donderdag", "Vrijdag", "Zaterdag"],
        sv: ["Söndag", "Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag"],
        da: ["Søndag", "Mandag", "Tirsdag", "Onsdag", "Torsdag", "Fredag", "Lørdag"],
        no: ["Søndag", "Mandag", "Tirsdag", "Onsdag", "Torsdag", "Fredag", "Lørdag"],
        fi: ["Sunnuntai", "Maanantai", "Tiistai", "Keskiviikko", "Torstai", "Perjantai", "Lauantai"],
        is: ["Sunnudagur", "Mánudagur", "Þriðjudagur", "Miðvikudagur", "Fimmtudagur", "Föstudagur", "Laugardagur"],
        pl: ["Niedziela", "Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota"],
        ro: ["Duminică", "Luni", "Marți", "Miercuri", "Joi", "Vineri", "Sâmbătă"],
        cs: ["Neděle", "Pondělí", "Úterý", "Středa", "Čtvrtek", "Pátek", "Sobota"],
        sk: ["Nedeľa", "Pondelok", "Utorok", "Streda", "Štvrtok", "Piatok", "Sobota"],
        hu: ["Vasárnap", "Hétfő", "Kedd", "Szerda", "Csütörtök", "Péntek", "Szombat"],
        hr: ["Nedjelja", "Ponedjeljak", "Utorak", "Srijeda", "Četvrtak", "Petak", "Subota"],
        sl: ["Nedelja", "Ponedeljek", "Torek", "Sreda", "Četrtek", "Petek", "Sobota"],
        lt: ["Sekmadienis", "Pirmadienis", "Antradienis", "Trečiadienis", "Ketvirtadienis", "Penktadienis", "Šeštadienis"],
        lv: ["Svētdiena", "Pirmdiena", "Otrdiena", "Trešdiena", "Ceturtdiena", "Piektdiena", "Sestdiena"],
        et: ["Pühapäev", "Esmaspäev", "Teisipäev", "Kolmapäev", "Neljapäev", "Reede", "Laupäev"],
        sq: ["E diel", "E hënë", "E martë", "E mërkurë", "E enjte", "E premte", "E shtunë"]

    };

    // Si el idioma está en el objeto, devuelve el día correspondiente; si no, devuelve en inglés por defecto.
    return daysOfWeek[language] ? daysOfWeek[language][dayIndex] : daysOfWeek["en"][dayIndex];
}

