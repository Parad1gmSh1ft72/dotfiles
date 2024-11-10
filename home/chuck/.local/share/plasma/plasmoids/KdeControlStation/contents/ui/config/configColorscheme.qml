import QtQml 2.0
import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_lightTheme: labelA.text // labels to store previous choices (ComboBox doesn't like to do it by itself)
    property alias cfg_darkTheme:  labelB.text // labels to store previous choices (ComboBox doesn't like to do it by itself)

    property alias cfg_lightGlobalTheme: labelC.text// labels to store previous choices (ComboBox doesn't like to do it by itself)
    property alias cfg_darkGlobalTheme:  labelD.text // labels to store previous choices (ComboBox doesn't like to do it by itself)
    
    property alias cfg_preferChangeGlobalTheme: preferChangeGlobalTheme.checked

    property string command: preferChangeGlobalTheme.checked ? 
                            "plasma-apply-lookandfeel --list" : 
                            "plasma-apply-colorscheme --list-schemes | tail --lines=+2"
    
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        signal colorsListReady(var colors)

        function exec(cmd) {
            connectSource(cmd)
        }

        onNewData: {
            var colors = data["stdout"].split("\n")
            if(!preferChangeGlobalTheme.checked) {
                for (var i = 0; i < colors.length; i++) { // parse command output
                    colors[i] = colors[i].substring(3).split(" ")[0]
                }
            } 
            colors.pop()
            colorsListReady(colors)
            disconnectSource(sourceName) // cmd finished
            
        }

    }

    // Copies of the last saved ComboBox entries.
    Label {
        id: labelA
        visible: false
    }
    Label {
        id: labelB
        visible: false
    }
   
    Label {
        id: labelC
        visible: false
    }
    Label {
        id: labelD
        visible: false
    }

    function setText(comboBox, text) { // comboboxes don't really allow to set current entry by text => manually search for them
        var found = false
        for (var colorIndex = 0; colorIndex < comboBox.count; colorIndex++) {
            if (comboBox.currentText === text) {
                found = true
                break
            }
            comboBox.incrementCurrentIndex()
        }
        if (!found)
            console.log("Color not found (perhaps it has been removed?).")
    }

    Connections {
        target: executable
        onColorsListReady: {
            cBoxA.model = colors
            cBoxB.model = colors
            // look for color in list

            setText(cBoxA, preferChangeGlobalTheme.checked ? labelC.text : labelA.text)
            setText(cBoxB,  preferChangeGlobalTheme.checked ? labelD.text : labelB.text)
            // enable changes user just after everything is set up
            cBoxA.isChangeAvailable = true
            cBoxB.isChangeAvailable = true
        }
    }

    ColumnLayout {
        
        CheckBox {
            id: preferChangeGlobalTheme
            text: i18n("Change global theme instead of just changing color scheme")
            onClicked: {
                executable.exec(command)
            }
        }
        GridLayout {
            columns: 2
            Label {
                Layout.row :0
                Layout.column: 0
                text: i18n("Light color")
            }

            ComboBox {
                id: cBoxA
                property bool isChangeAvailable: false

                Layout.row: 0
                Layout.column: 1
                Layout.minimumWidth: 300
                onCurrentTextChanged: {
                    var targetLabel =  preferChangeGlobalTheme.checked ? labelC : labelA
                    if (isChangeAvailable)
                        targetLabel.text = currentText
                }
            }

            Label {
                Layout.row :1
                Layout.column: 0
                text: i18n("Dark color")
            }

            ComboBox {
                id: cBoxB
                property bool isChangeAvailable: false

                Layout.row: 1
                Layout.column: 1
                Layout.minimumWidth: 300

                onCurrentTextChanged: {
                    var targetLabel =  preferChangeGlobalTheme.checked ? labelD : labelB
                    if (isChangeAvailable)
                       targetLabel.text = currentText
                        console.log(targetLabel.text)
                }
            }
        }
    }

    Component.onCompleted: {
        executable.exec(command)
    }
}
