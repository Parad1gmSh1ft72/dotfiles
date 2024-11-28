import QtQuick 2.5
import org.kde.plasma.plasma5support as Plasma5Support
Image {
    id: root

    property url urlwallpaper: ""
    property string base: "ffffff"

    Plasma5Support.DataSource {

        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd) {
            connectSource(cmd)
        }
        signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }

    //Image {
        //id:  edit
        //source: urlwallpaper
        //visible: false
    //}

    Connections {
        target: executable
        onExited: {
            // Limpiamos cualquier espacio en blanco o saltos de línea
            var output = stdout.trim();

            // Verificamos que el comando se ejecutó correctamente y que la salida contiene una extensión válida
            if (exitCode === 0 && (output.endsWith(".png") || output.endsWith(".jpg") || output.endsWith(".jpeg"))) {
                urlwallpaper = output;
                source = urlwallpaper;
            } else {
                console.error("No se obtuvo una imagen válida o hubo un error en el script:", stderr);
            }
        }
    }

   source: "images/background.jpg"

   Canvas {
       id: canvas
       width: edit.width
       height: edit.height
       onPaint: {
           var ctx = getContext("2d");
           ctx.drawImage(edit, 0, 0); // Dibuja la imagen en el canvas

           // Obtener el color del centro de la imagen
           var centerX = width / 2;
           var centerY = height / 2;

           // Leer píxeles alrededor del centro
           var imageData = ctx.getImageData(centerX - 5, centerY - 5, 10, 10);
           var data = imageData.data;

           var r = 0, g = 0, b = 0;
           var pixelCount = data.length / 4; // Cada pixel tiene 4 valores (R, G, B, A)

           // Calcular el promedio de los colores
           for (var i = 0; i < data.length; i += 4) {
               r += data[i];     // R
               g += data[i + 1]; // G
               b += data[i + 2]; // B
           }
           r /= pixelCount;
           g /= pixelCount;
           b /= pixelCount;

           // Determinar si el color es claro u oscuro
           var brightness = (r + g + b) / 3; // Promedio simple de brillo
           var isLight = brightness > 127; // Umbral para determinar claro/oscuro


           base = isLight ? "000000" : "ffffff"
       }
   }

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }
    Image {
        id: img1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: -50

        source: "images/kde.svgz"
        sourceSize: Qt.size( root.height* 0.15,root.height* 0.15)
    }

    Rectangle {
        radius: 4
        color: "#66" + base
        anchors {
            top: img1.bottom
            topMargin: 48
            horizontalCenter: img1.horizontalCenter
        }
        height: 6
        width: root.width*0.2
        Rectangle {
            radius: 4
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: (parent.width / 6) * (stage - 1)
            color: "#" + base
            Behavior on width {
                PropertyAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }


    SequentialAnimation {
        id: introAnimation
        running: false


        ParallelAnimation {
            loops: Animation.Infinite
            SequentialAnimation{
                PropertyAnimation {
                    property: "scale"
                    target: img1
                    from: 0.9
                    to: 1.1
                    duration: 800
                    easing.type: Easing.InBack
                }

                PropertyAnimation {
                    property: "scale"
                    target: img1
                    from: 1.1
                    to: 0.9
                    duration: 800
                    easing.type:Easing.OutBack
                }

            }
        }
    }
    Component.onCompleted: {
        executable.exec("bash $HOME/.local/share/plasma/look-and-feel/AppleSplash/contents/lib/find.sh")
        //source = "images/background.jpg"
    }
}
