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

function desktoptext(languageCode) {
    const translations = {
        "es": "Escritorio",         // Spanish
        "en": "Desktop",            // English
        "hi": "डेस्कटॉप",           // Hindi
        "fr": "Bureau",             // French
        "de": "Desktop",            // German
        "it": "Desktop",            // Italian
        "pt": "Área de trabalho",   // Portuguese
        "ru": "Рабочий стол",       // Russian
        "zh": "桌面",               // Chinese (Mandarin)
        "ja": "デスクトップ",        // Japanese
        "ko": "데스크톱",            // Korean
        "nl": "Bureaublad",         // Dutch
        "ny": "Detskyopi",          // Chichewa
        "mk": "Десктоп"             // Macedonian
    };

    // Return the translation for the language code or default to English if not found
    return translations[languageCode] || translations["en"];
}
/*kapple*/
separators(paneltop)

kpple = paneltop.addWidget("org.kpple.kppleMenu")
kpple.currentConfigGroup = ["Configuration"]
kpple.writeConfig("popupWidth", "400")

paneltop.addWidget("org.kde.plasma.marginsseparator")

apptitle = paneltop.addWidget("org.kde.windowtitle.Fork")
apptitle.currentConfigGroup = ["General"]
apptitle.writeConfig("customText", "true")
apptitle.writeConfig("showIcon", "false")
apptitle.writeConfig("textDefault", desktoptext(textlengu))

paneltop.addWidget("org.kde.plasma.appmenu")

paneltop.addWidget("org.kde.plasma.panelspacer")
systraprev = paneltop.addWidget("org.kde.plasma.systemtray")
SystrayContainmentId = systraprev.readConfig("SystrayContainmentId")
const systray = desktopById(SystrayContainmentId)
systray.currentConfigGroup = ["General"]
systray.writeConfig("iconSpacing", "6")

paneltop.addWidget("org.kde.plasma.marginsseparator")

paneltop.addWidget("Plasma.Control.Hub")

paneltop.addWidget("org.kde.plasma.marginsseparator")

fecha = paneltop.addWidget("com.github.zren.commandoutput")
fecha.currentConfigGroup = ["General"]
fecha.writeConfig("command", `echo "$(date +"%a" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') $(date +"%d") "`)
fecha.writeConfig("bold", "true")
fecha.writeConfig("fontSize", "10")

separatorofDate = paneltop.addWidget("zayron.simple.separator")
separatorofDate.currentConfigGroup = ["General"]
separatorofDate.writeConfig("lengthMargin", "5")
separatorofDate.writeConfig("lengthSeparator", "50")
separatorofDate.writeConfig("thicknessSeparator", "2")

clock = paneltop.addWidget("org.kde.plasma.digitalclock")
clock.currentConfigGroup = ["Appearance"]
clock.writeConfig("dateFormat", "custom")
clock.writeConfig("showDate", "false")
clock.writeConfig("dateDisplayFormat", "BesideTime")
clock.writeConfig("fontStyleName", "bold")
clock.writeConfig("autoFontAndSize", "false")
clock.writeConfig("boldText", "true")
clock.writeConfig("fontWeight", 700)
clock.writeConfig("use24hFormat", "2")

separators(paneltop)
/****************************/
panelbottom = new Panel
panelbottom.location = "bottom"
panelbottom.height = 66
panelbottom.offset = 0
panelbottom.floating = 1
panelbottom.alignment = "center"
panelbottom.hiding = "dodgewindows"
panelbottom.lengthMode = "fit"
panelbottom.addWidget("org.kde.plasma.marginsseparator")

menu = panelbottom.addWidget("AndromedaLauncher")
menu.currentConfigGroup = ["General"]
menu.writeConfig("activationIndicator", "false")
menu.writeConfig("customButtonImage", "app-launcher")
menu.writeConfig("floating", "true")
menu.writeConfig("launcherPosition", "1")
menu.writeConfig("useCustomButtonImage", "true")

panelbottom.addWidget("org.kde.plasma.icontasks")
panelbottom.addWidget("org.kde.plasma.marginsseparator")
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