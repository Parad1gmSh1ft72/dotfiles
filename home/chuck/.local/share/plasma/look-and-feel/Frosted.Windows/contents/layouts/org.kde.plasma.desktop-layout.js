/*******Panel Top*********/
paneltop = new Panel
paneltop.hiding = "none"
paneltop.location = "top"
paneltop.height = 24
paneltop.lengthMode = "custom"
paneltop.floating = 0
const width = screenGeometry(paneltop.screen).width
paneltop.maximumLength = width *.9
paneltop.minimumLength  = paneltop.maximumLength

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

menu = paneltop.addWidget("Compact.Menu")
menu.currentConfigGroup = ["General"]
menu.writeConfig("displayPosition", "Default")
menu.writeConfig("icon", "start-here-kde-symbolic")
menu.writeConfig("forceColor", "true")
menu.writeConfig("useCustomButtonImage", "true")
menu.writeConfig("customButtonImage", `${userDataPath()}/.local/share/plasma/desktoptheme/Frosted/icons/start.svg`)

paneltop.addWidget("org.kde.plasma.marginsseparator")

apptitle = paneltop.addWidget("org.kde.windowtitle.Fork")
apptitle.currentConfigGroup = ["General"]
apptitle.writeConfig("customText", "true")
apptitle.writeConfig("showIcon", "false")
apptitle.writeConfig("textDefault", desktoptext(textlengu))

paneltop.addWidget("org.kde.plasma.appmenu")

paneltop.addWidget("org.kde.plasma.panelspacer")
systraprev = paneltop.addWidget("org.kde.plasma.systemtray")
paneltop.addWidget("org.kde.plasma.marginsseparator")
paneltop.addWidget("Plasma.Control.Hub")
SystrayContainmentId = systraprev.readConfig("SystrayContainmentId")
const systray = desktopById(SystrayContainmentId)
systray.currentConfigGroup = ["General"]
systray.writeConfig("iconSpacing", "6")

paneltop.addWidget("org.kde.plasma.marginsseparator")

fecha = paneltop.addWidget("com.github.zren.commandoutput")
fecha.currentConfigGroup = ["General"]
fecha.writeConfig("command", `echo "$(date +"%a" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') $(date +"%d") $(date +"%b" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"`)
fecha.writeConfig("bold", "true")
fecha.writeConfig("fontSize", "10")

clock = paneltop.addWidget("org.kde.plasma.digitalclock")
clock.currentConfigGroup = ["Appearance"]
clock.writeConfig("customDateFormat", "ddd d MMM")
clock.writeConfig("dateFormat", "custom")
clock.writeConfig("showDate", "false")
clock.writeConfig("dateDisplayFormat", "BesideTime")
clock.writeConfig("fontStyleName", "bold")
clock.writeConfig("autoFontAndSize", "false")
clock.writeConfig("boldText", "true")
clock.writeConfig("fontWeight", 700)
clock.writeConfig("use24hFormat", "0")

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
panelbottom.addWidget("org.kde.plasma.icontasks")
panelbottom.addWidget("zayron.simple.separator")
panelbottom.addWidget("org.kde.plasma.marginsseparator")
panelbottom.addWidget("org.kde.plasma.calculator")
/*Trash*/
panelbottom.addWidget("org.kde.plasma.trash")
/*separator*/
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
Buttons.writeEntry("ButtonsOnRight", "IAX")
Buttons.writeEntry("ButtonsOnLeft", "")
/******************************/
/* accent color config*/
ColorAccetFile = ConfigFile("kdeglobals")
ColorAccetFile.group = "General"
ColorAccetFile.writeEntry("accentColorFromWallpaper", "false")
ColorAccetFile.deleteEntry("AccentColor")
ColorAccetFile.deleteEntry("LastUsedCustomAccentColor")
