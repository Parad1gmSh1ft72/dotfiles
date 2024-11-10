var plasma = getApiVersion(1);
/*General*/
panelbottom = new Panel
panelbottom.location = "bottom"
panelbottom.height = gridUnit * 2.48
panelbottom.hiding = "none"
panelbottom.lengthMode = "custom"
panelbottom.floating = 0
const width = screenGeometry(panelbottom.screen).width
panelbottom.maximumLength = width - 2
panelbottom.minimumLength  = panelbottom.maximumLength
/*App Launcher*/
menu = panelbottom.addWidget("Start.11.Simple")
menu.currentConfigGroup = ["General"]
menu.writeConfig("icon", `${userDataPath()}/.local/share/plasma/desktoptheme/ChromeOsKde.v2/icons/start.svg`)
menu.writeConfig("displayPosition", "Default")
/*spacer*/
panelbottom.addWidget("org.kde.plasma.panelspacer")

/*Find-Widget*/
panelbottom.addWidget("org.kde.plasma.icontasks")
panelbottom.addWidget("org.kde.plasma.panelspacer")
/*systemtray*/
var systraprev = panelbottom.addWidget("org.kde.plasma.systemtray")
var SystrayContainmentId = systraprev.readConfig("SystrayContainmentId")
const systray = desktopById(SystrayContainmentId)
systray.currentConfigGroup = ["General"]
systray.writeConfig("iconSpacing", 3)
panelbottom.addWidget("Plasma.Control.Hub")
/*Cambiando configuracion Dolphin*/
const IconsStatic_dolphin = ConfigFile('dolphinrc')
IconsStatic_dolphin.group = 'KFileDialog Settings'
IconsStatic_dolphin.writeEntry('Places Icons Static Size', 16)
const PlacesPanel = ConfigFile('dolphinrc')
PlacesPanel.group = 'PlacesPanel'
PlacesPanel.writeEntry('IconSize', 16)
/******************************/
/*Clock*/
panelbottom_clock = panelbottom.addWidget("org.kde.plasma.digitalclock")
panelbottom_clock.currentConfigGroup = ["Appearance"]
panelbottom_clock.writeConfig("fontSize", "12")
panelbottom_clock.writeConfig("dateDisplayFormat", "BesideTime")
panelbottom_clock.writeConfig("dateFormat", "custom")
panelbottom_clock.writeConfig("customDateFormat", "dddd d")
panelbottom_clock.writeConfig("autoFontAndSize", "false")
/* accent color config*/
ColorAccetFile = ConfigFile("kdeglobals")
ColorAccetFile.group = "General"
ColorAccetFile.writeEntry("accentColorFromWallpaper", "false")
ColorAccetFile.deleteEntry("AccentColor")
ColorAccetFile.deleteEntry("LastUsedCustomAccentColor")
/*Clock, Weather Widget*/
let desktopsArray = desktopsForActivity(currentActivity());
for( var j = 0; j < desktopsArray.length; j++) {
    var desktopByClock = desktopsArray[j]
}
const NumX = Number(((screenGeometry(desktopByClock).width)-736)-40)
const NumY = 50
desktopByClock.addWidget("Seeua.Weather", NumX, NumY, 656, 384)
/*Buttons of aurorae*/
Buttons = ConfigFile("kwinrc")
Buttons.group = "org.kde.kdecoration2"
Buttons.writeEntry("ButtonsOnRight", "IAX")
Buttons.writeEntry("ButtonsOnLeft", "")
plasma.loadSerializedLayout(layout);
