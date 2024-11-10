import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support
import "components" as Components

KCM.SimpleKCM {
    id:root
    property bool cfg_isEnabled
    property string presetsDir: StandardPaths.writableLocation(
                    StandardPaths.HomeLocation).toString().substring(7) + "/.config/panel-colorizer/"
    property string cratePresetsDirCmd: "mkdir -p " + presetsDir
    property string listPresetsCmd: "find "+presetsDir+" -type f -print0 | while IFS= read -r -d '' file; do basename \"$file\"; done | sort"

    property string cfg_normalPreset
    property string cfg_floatingPreset
    property string cfg_touchingWindowPreset
    property string cfg_maximizedPreset

    ListModel {
        id: presetsModel
    }

    P5Support.DataSource {
        id: runCommand
        engine: "executable"
        connectedSources: []

        onNewData: function (source, data) {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(source, exitCode, exitStatus, stdout, stderr)
            disconnectSource(source) // cmd finished
        }

        function exec(cmd) {
            runCommand.connectSource(cmd)
        }

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }

    Connections {
        target: runCommand
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            // console.log(cmd);
            if (exitCode!==0) return
            // console.log(stdout);
            var presets = []
            if(cmd === listPresetsCmd) {
                if (stdout.length < 1) return
                presetsModel.append(
                    {
                        "name": i18n("Do nothing"),
                        "value": ""
                    }
                )
                presets = stdout.trim().split("\n")
                for (let i = 0; i < presets.length; i++) {
                    presets[i]
                    presetsModel.append(
                        {
                            "name": presets[i],
                            "value": presets[i],
                        }
                    )
                }
            }
        }
    }

    function getIndex(model, savedValue) {
        for (let i = 0; i < model.count; i++) {
            if (model.get(i).value === savedValue) {
                return i;
            }
        }
        return -1;
    }

    function dumpProps(obj) {
        console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        for (var k of Object.keys(obj)) {
            print(k + "=" + obj[k]+"\n")
        }
    }

    Component.onCompleted: {
        runCommand.exec(cratePresetsDirCmd)
        runCommand.exec(listPresetsCmd)
    }

    header: RowLayout {
        RowLayout {
            Layout.leftMargin: Kirigami.Units.mediumSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Item {
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Label {
                    text: i18n("Last preset loaded:")
                }
                Label {
                    text: plasmoid.configuration.lastPreset || "None"
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    ColumnLayout {
        visible: cfg_isEnabled
        Label {
            text: i18n("Here you can switch between different panel presets based on the Panel and window states below.")
            Layout.maximumWidth: root.width - (Kirigami.Units.gridUnit * 2)
            wrapMode: Text.Wrap
        }

        Label {
            text: i18n("Priorities go from lowest to highest. E.g. if both <b>Maximized window is shown</b> and <b>Panel touching window</b> have a preset selected, and there is a maximized window on the screen, the <b>Maximized</b> preset will be applied.")
            Layout.maximumWidth: root.width - (Kirigami.Units.gridUnit * 2)
            wrapMode: Text.Wrap
        }
        Kirigami.FormLayout {

            ComboBox {
                id: normalPreset
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Normal:")
                onCurrentIndexChanged: {
                    cfg_normalPreset = model.get(currentIndex)["value"]
                }
                currentIndex: getIndex(model, cfg_normalPreset)
            }

            ComboBox {
                id: floatingPreset
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Floating panel:")
                onCurrentIndexChanged: {
                    cfg_floatingPreset = model.get(currentIndex)["value"]
                }
                currentIndex: getIndex(model, cfg_floatingPreset)
            }

            ComboBox {
                id: touchingWindowPreset
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Window touching panel:")
                onCurrentIndexChanged: {
                    cfg_touchingWindowPreset = model.get(currentIndex)["value"]
                }
                currentIndex: getIndex(model, cfg_touchingWindowPreset)
            }

            ComboBox {
                id: maximizedPreset
                model: presetsModel
                textRole: "name"
                Kirigami.FormData.label: i18n("Maximized window is shown:")
                onCurrentIndexChanged: {
                    cfg_maximizedPreset = model.get(currentIndex)["value"]
                }
                currentIndex: getIndex(model, cfg_maximizedPreset)
            }
        }
    }

    Components.CategoryDisabled {
        visible: !cfg_isEnabled
    }
}
