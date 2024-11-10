/*******Panel Top*********/
paneltop = new Panel
paneltop.hiding = "none"
paneltop.location = "top"
paneltop.floating = 0
paneltop.height = 24
paneltop.lengthMode = "fill"
/****conociendo la resolucion de pantalla*/
const width = screenGeometry(paneltop.screen).width
/**/
function separators(a){
    if (width <= 1280){
        c = 1
    } else { if (width <= 1440){
        c = 2
    } else
    {
        c = 3
    }
    }
    for (b = 0; b < c; b++)
        a.addWidget("org.kde.plasma.marginsseparator")
}
function separatorsTray(){
    if (width <= 1280){
        c = 2
    } else { if (width <= 1440){
        c = 4
    } else
    {
        c = 6
    }
    }
    return c
}

let localerc;
try {
    localerc = ConfigFile('plasma-localerc');
    localerc.group = "Formats";
} catch (e) {
    // Si no se puede abrir el archivo, establecer leng a "en"
    localerc = null;
}

let leng = "en"; // Valor por defecto
if (localerc) {
    let langEntry = localerc.readEntry("LANG");
    if (langEntry !== "") {
        leng = langEntry;
    }
}

let textlengu = leng.substring(0, 2);
function activitiesText(languageCode) {
    const translations = {
        "es": "Actividades",       // Spanish
        "en": "Activities",        // English
        "hi": "गतिविधियाँ",        // Hindi
        "fr": "Activités",         // French
        "de": "Aktivitäten",       // German
        "it": "Attività",          // Italian
        "pt": "Atividades",        // Portuguese
        "ru": "Деятельность",      // Russian
        "zh": "活动",              // Chinese (Mandarin)
        "ja": "アクティビティ",     // Japanese
        "ko": "활동",              // Korean
        "nl": "Activiteiten",      // Dutch
        "ny": "Zochitika",         // Chichewa
        "mk": "Активности"         // Macedonian
    };

    // Return the translation for the language code or default to English if not found
    return translations[languageCode] || translations["en"];
}

/*kapple*/
separators(paneltop)

activi = paneltop.addWidget("runcommand.fork")
activi.currentConfigGroup = ["General"]
activi.writeConfig("icon", "")
activi.writeConfig("textBold", "true")
activi.writeConfig("command", "")
activi.writeConfig("menuLabel", activitiesText(textlengu))

paneltop.addWidget("org.kde.plasma.panelspacer")
fecha = paneltop.addWidget("com.github.zren.commandoutput")
fecha.currentConfigGroup = ["General"]
fecha.writeConfig("command", `echo "$(date +"%a" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"`)
fecha.writeConfig("bold", "true")
fecha.writeConfig("fontSize", "10")

clock = paneltop.addWidget("org.kde.plasma.digitalclock")
clock.currentConfigGroup = ["Appearance"]
clock.writeConfig("customDateFormat", "d")
clock.writeConfig("dateFormat", "custom")
//clock.writeConfig("showDate", "false")
clock.writeConfig("dateDisplayFormat", "BesideTime")
clock.writeConfig("fontStyleName", "bold")
clock.writeConfig("autoFontAndSize", "false")
clock.writeConfig("boldText", "true")
clock.writeConfig("fontWeight", 700)
clock.writeConfig("use24hFormat", "0")

paneltop.addWidget("org.kde.plasma.panelspacer")

systraprev = paneltop.addWidget("org.kde.plasma.systemtray")
SystrayContainmentId = systraprev.readConfig("SystrayContainmentId")
const systray = desktopById(SystrayContainmentId)
systray.currentConfigGroup = ["General"]
systray.writeConfig("iconSpacing", "6")

paneltop.addWidget("org.kde.plasma.marginsseparator")


separators(paneltop)
/****************************/
panelbottom = new Panel
panelbottom.location = "bottom"
panelbottom.height = 62
panelbottom.offset = 0
panelbottom.floating = 1
panelbottom.alignment = "center"
panelbottom.hiding = "dodgewindows"
panelbottom.lengthMode = "fit"
panelbottom.addWidget("org.kde.plasma.marginsseparator")

panelbottom.addWidget("org.kde.plasma.icontasks")
panelbottom.addWidget("zayron.simple.separator")
/*separator*/
panelbottom.addWidget("org.kde.plasma.marginsseparator")

menu = panelbottom.addWidget("adhe.launchpadPlasma")
menu.currentConfigGroup = ["General"]
menu.writeConfig("icon", `${userDataPath()}/.local/share/plasma/look-and-feel/kdewaita/contents/icons/menu.svg`)
/*separator /*/
/******************************/
/*Cambiando configuracion Dolphin*/
const IconsStatic_dolphin = ConfigFile('dolphinrc')
IconsStatic_dolphin.group = 'KFileDialog Settings'
IconsStatic_dolphin.writeEntry('Places Icons Static Size', 16)
const PlacesPanel = ConfigFile('dolphinrc')
PlacesPanel.group = 'PlacesPanel'
PlacesPanel.writeEntry('IconSize', 16)
/*Buttons of aurorae*/
Buttons = ConfigFile("kwinrc")
Buttons.group = "org.kde.kdecoration2"
Buttons.writeEntry("ButtonsOnRight", "")
Buttons.writeEntry("ButtonsOnLeft", "XIA")
/******************************/
/* accent color config*/
ColorAccetFile = ConfigFile("kdeglobals")
ColorAccetFile.group = "General"
ColorAccetFile.writeEntry("accentColorFromWallpaper", "false")
ColorAccetFile.deleteEntry("AccentColor")
ColorAccetFile.deleteEntry("LastUsedCustomAccentColor")
