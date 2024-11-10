var panel = new Panel
panel.location = "bottom"
panel.hiding = "none"
panel.height = 50
panel.alignment = "center"
panel.floating = 1
panel.lengthMode = "fill"
const width = screenGeometry(panel.screen).width

panel_start = panel.addWidget("Start.Next.Menu")
panel_start.currentConfigGroup = ["General"]
panel_start.writeConfig("displayPosition", "Default")
panel_start.writeConfig("icon", `${userDataPath()}/.local/share/plasma/desktoptheme/Amethyst.Haze/icons/start.svg`)

panel_showd = panel.addWidget("org.kde.plasma.showdesktop")
panel_showd.currentConfigGroup = ["General"]
panel_showd.writeConfig("icon", "deepin-show-desktop")

separator = panel.addWidget("zayron.simple.separator")
separator.currentConfigGroup = ["General"]
separator.writeConfig("lengthSeparator", 50)
separator.writeConfig("opacity", 75)

panel.addWidget("org.kde.plasma.panelspacer")
panel.addWidget("org.kde.plasma.icontasks")

panel.addWidget("org.kde.plasma.panelspacer")
separatordos = panel.addWidget("zayron.simple.separator")
separatordos.currentConfigGroup = ["General"]
separatordos.writeConfig("lengthSeparator", 50)
separatordos.writeConfig("opacity", 75)
/*systemtray*/
var systraprev = panel.addWidget("org.kde.plasma.systemtray")
var SystrayContainmentId = systraprev.readConfig("SystrayContainmentId")
const systray = desktopById(SystrayContainmentId)
systray.currentConfigGroup = ["General"]
let ListTrays = systray.readConfig("extraItems")
systray.writeConfig("iconSpacing", 1)
systray.writeConfig("hiddenItems", "Notificador de Discover_org.kde.DiscoverNotifier")

panel_clock = panel.addWidget("org.kde.plasma.digitalclock")
panel_clock.currentConfigGroup = ["Appearance"]
panel_clock.writeConfig("fontSize", "14")
panel_clock.writeConfig("autoFontAndSize", "false")

panel.addWidget("org.kde.plasma.trash")
/*Buttons of aurorae*/
Buttons = ConfigFile("kwinrc")
Buttons.group = "org.kde.kdecoration2"
Buttons.writeEntry("ButtonsOnRight", "IAX")
Buttons.writeEntry("ButtonsOnLeft", "")

/* accent color config*/
ColorAccetFile = ConfigFile("kdeglobals")
ColorAccetFile.group = "General"
ColorAccetFile.writeEntry("accentColorFromWallpaper", "false")
ColorAccetFile.deleteEntry("AccentColor")
ColorAccetFile.deleteEntry("LastUsedCustomAccentColor")

/*Clock, Weather and Music Widget*/
let desktopsArray = desktopsForActivity(currentActivity());
for( var j = 0; j < desktopsArray.length; j++) {
var desktopByClock = desktopsArray[j]
}

clock_desktop = desktopByClock.addWidget("Redmi.Clock", 20, 20, 256, 256)
clock_desktop.currentConfigGroup = ["General"]
clock_desktop.writeConfig("colorHex", "#18131e")



