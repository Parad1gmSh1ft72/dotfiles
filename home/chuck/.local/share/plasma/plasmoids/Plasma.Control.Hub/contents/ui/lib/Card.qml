import QtQuick 2.15
//import QtQml 2.0
//import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import Qt5Compat.GraphicalEffects
//import org.kde.plasma.core 2.0 as PlasmaCore
//import org.kde.plasma.components as PlasmaComponents
import org.kde.ksvg as KSvg

Rectangle {
    color: "transparent"

        KSvg.FrameSvgItem {
            id: segment // seccion de botones de red, bluetooth y config
            imagePath: "widgets/background"
            clip: true
            anchors.left:  parent.left
            anchors.leftMargin: - segment.margins.left *.5
            anchors.top: parent.top
            anchors.topMargin: - segment.margins.top *.5
            width: parent.width + segment.margins.left *.8
            height: parent.height + segment.margins.top *.8
            //enabledBorders: TopBorder | BottomBorder | LeftBorder | RightBorder
            opacity: 0.7
        }

        Rectangle {
            id: mask
            width: segment.width
            height: segment.height
            color: "transparent"
            visible: false
            KSvg.FrameSvgItem {
                imagePath: "widgets/translucentbackground"
                anchors.centerIn: parent
                width: segment.width
                height: segment.height
                //enabledBorders: TopBorder | BottomBorder | LeftBorder | RightBorder
                //visible: true
            }
            KSvg.FrameSvgItem {
                imagePath: "widgets/translucentbackground"
                anchors.centerIn: parent
                width: segment.width
                height: segment.height
                //enabledBorders: TopBorder | BottomBorder | LeftBorder | RightBorder
                //visible: true
            }
            KSvg.FrameSvgItem {
                imagePath: "widgets/translucentbackground"
                anchors.centerIn: parent
                width: segment.width
                height: segment.height
                //enabledBorders: TopBorder | BottomBorder | LeftBorder | RightBorder
                //visible: true
            }


        }

        DropShadow {
            id: sha
            anchors.fill: segment
            horizontalOffset: 0
            verticalOffset: 0
            radius: 7.0
            //color: "red"
            opacity: 0.6
            visible: true
            source: segment
            //clipMode: DropShadow.Unclipped
            //transparentBorder: false
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource:  mask
                invert: true
            }

        }
}
