/*
 *  SPDX-FileCopyrightText: zayronxio
 *  SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.15
import org.kde.plasma.private.volume

Item {
    id: spectrum
    width: 100 // Asegúrate de definir un alto para el contenedor
    property var sink: PreferredDevice.sink
    property color colorBars: "white"
    property bool active: true
    property int numberBar: 9
    property real previousVolume: -1
    property int plasmoidwidth: 0
    property var pattern: []
    property int widthBars: plasmoid.configuration.barsWidth
    property int separatorBars:  plasmoid.configuration.barsSeparation
    property bool anchorToBottom: plasmoid.configuration.displayPosition === 0 ? true : false


    VolumeMonitor {
        id: volumeMonitor
        target: sink
    }

    function calculateBars(width, widthOfBar, separation) {
        // Calcular la cantidad de elementos que caben en el ancho disponible
        return Math.floor(width / (widthOfBar + separation));
    }

    function clearBars() {
        // Eliminar todas las barras anteriores
        for (var o = 0; o < bar.children.length; o ++){
             bar.children[o].destroy();
        }
        console.log("el numero de barras actual es",  widthBars )
    }

    function llenarArray(width, widthOfBar, separation) {
        // Limpiar las barras previas antes de generar nuevas
        //clearBars();

        const cantidad = calculateBars(width, widthOfBar, separation);
        pattern = new Array(cantidad);

        if (cantidad === 0) return;

        const valorCentral = 1;
        const valorBorde = 0.2;

        if (cantidad % 2 === 1) {
            const centralIndex = Math.floor(cantidad / 2);
            pattern[centralIndex] = valorCentral;
        } else {
            const centralIndex1 = (cantidad / 2) - 1;
            const centralIndex2 = cantidad / 2;
            pattern[centralIndex1] = valorCentral;
            pattern[centralIndex2] = valorCentral;
        }

        pattern[0] = valorBorde;
        pattern[cantidad - 1] = valorBorde;

        const valorIntermedioMax = valorCentral;
        const valorIntermedioMin = valorBorde;

        for (let i = 1; i < cantidad - 1; i++) {
            if (pattern[i] === undefined) {
                const porcentaje = (i - 1) / (cantidad - 3);
                pattern[i] = valorIntermedioMin + (valorIntermedioMax - valorIntermedioMin) * porcentaje;
            }
        }
        bar.generateRectangles();
    }

    Timer {
        id: updateTimer
        interval: 50
        running: true
        repeat: true
        onTriggered: {
            bar.updateRectangles();
        }
    }

    onActiveChanged: {
        bar.visible = active;
    }

    onSeparatorBarsChanged: {
        clearBars();
        llenarArray(plasmoidwidth, widthBars, separatorBars);
    }
    onWidthBarsChanged: {
        clearBars();
        llenarArray(plasmoidwidth, widthBars, separatorBars);
    }
    onAnchorToBottomChanged: {
        clearBars();
        llenarArray(plasmoidwidth, widthBars, separatorBars);
    }
    onPlasmoidwidthChanged: {
        clearBars();
        llenarArray(plasmoidwidth, widthBars, separatorBars);
    }

    Row {
        id: bar
        height: parent.height
        spacing: separatorBars

        width: parent.width
        visible: active
        anchors.centerIn: parent
        anchors.left: parent.left
        property int widths: parent.height > 32 ? parent.height * 0.1 : parent.height * 0.14

        function generateRectangles() {
            if(anchorToBottom) {
                for (let i = 0; i < pattern.length; i++) {
                    createRectangle(i, pattern[i]);
                }
            } else {
                for (let i = 0; i < pattern.length; i++) {
                    createRectangleTop(i, pattern[i]);
                }
            }

        }

        Component.onCompleted: {
            llenarArray(plasmoidwidth, widthBars, separatorBars);
        }



        function createRectangle(index, initialHeight) {
            const rect = Qt.createQmlObject('import QtQuick 2.15; Rectangle { \
            id: rect' + index + '; \
            width: ' + widthBars + '; \
            radius: 0; \
            color: colorBars; \
            height: width; \
            anchors.bottom: parent.bottom; \
            property real oneHeight: ' + initialHeight + '; \
            SequentialAnimation { \
            id: heightAnimation' + index + '; \
            running: true; \
            loops: Animation.Infinite; \
            PropertyAnimation { \
            target: parent; \
            property: "height"; \
            to: initialHeight; \
            duration: 100; \
            easing.type: Easing.InOutQuad; \
        } \
        } \
        }', bar);

            rect.anchors.verticalCenter = parent.verticalCenter;
            rect.x = index * (rect.width + spacing); // Posición horizontal calculada correctamente
        }

        function createRectangleTop(index, initialHeight) {
            const rect = Qt.createQmlObject('import QtQuick 2.15; Rectangle { \
            id: rect' + index + '; \
            width: ' + widthBars + '; \
            radius: 0; \
            color: colorBars; \
            height: width; \
            anchors.top: parent.top; \
            property real oneHeight: ' + initialHeight + '; \
            SequentialAnimation { \
            id: heightAnimation' + index + '; \
            running: true; \
            loops: Animation.Infinite; \
            PropertyAnimation { \
            target: parent; \
            property: "height"; \
            to: initialHeight; \
            duration: 100; \
            easing.type: Easing.InOutQuad; \
        } \
        } \
        }', bar);

            rect.anchors.verticalCenter = parent.verticalCenter;
            rect.x = index * (rect.width + spacing); // Posición horizontal calculada correctamente
        }

        function getRandomNumber(min, max) {
            return Math.random() * (max - min) + min;
        }

        function returnZero() {
            const num = Math.random() * (1 - 0) + 0;
            return num < 0.5 ? 0 : 1;
        }

        function updateRectangles() {
            let volumeFactor = volumeMonitor.volume * 20;

            for (let i = 0; i < bar.children.length; i++) {
                let rect = bar.children[i];
                let randomFactor = getRandomNumber(0, pattern.length < 60 ? pattern.length/5 : pattern.length/10);
                let baseHeight = ((volumeFactor * randomFactor * returnZero()) * pattern[i])
                rect.oneHeight = baseHeight + pattern[i]*2 * randomFactor * volumeMonitor.volume + 6;
                rect.height = rect.oneHeight
            }
        }
    }

    Connections {
        target: volumeMonitor
        onVolumeChanged: {
            if (Math.abs(volumeMonitor.volume - previousVolume) > 1) {
                previousVolume = volumeMonitor.volume;
                bar.updateRectangles();
                updateTimer.restart();
            }
        }
    }
}


