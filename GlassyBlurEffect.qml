import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Window {
    id: mainWindow
    visible: true
    width: 640
    height: 480
    title: "Draggable Glass Overlay"

    // Background content
    Rectangle {
        id: backgroundContent
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#2c3e50" }
            GradientStop { position: 1.0; color: "#3498db" }
        }

        Text {
            anchors.centerIn: parent
            text: "Hello Kutyr afffffffffffffffffffffffffffffffffs"
            font.pixelSize: 36
            font.bold: true
            color: "white"
        }
    }

    // Draggable Glass Overlay
    Item {
        id: glassOverlay
        width: 300
        height: 200
        clip: true
        anchors.centerIn: parent
        // radius: 20
        // property bool dragging: false
        // property real dragStartX: 0
        // property real dragStartY: 0

        // // Position control
        // x: Math.min(Math.max(width / 2, 0), mainWindow.width - width)
        // y: Math.min(Math.max(height / 2, 0), mainWindow.height - height)

        ShaderEffectSource {
            id: blurSource
            anchors.fill: parent
            sourceItem: backgroundContent
            live: true
            hideSource: false
            // sourceRect must update based on overlay position in backgroundContent coords
            sourceRect: Qt.rect(glassOverlay.x, glassOverlay.y, glassOverlay.width, glassOverlay.height)
        }

        MultiEffect {
            anchors.fill: parent
            source: blurSource
            blurEnabled: true
            blur: 1.0
            blurMax: 32
        }

        Rectangle {
            anchors.fill: parent
            color: "#FFFFFF"  // 20% white overlay
            opacity: 0.05
            radius: 20
        }

        // MouseArea {
        //     anchors.fill: parent
        //     drag.target: glassOverlay
        //     drag.axis: Drag.XAndYAxis
        //     drag.minimumX: 0
        //     drag.minimumY: 0
        //     drag.maximumX: mainWindow.width - glassOverlay.width
        //     drag.maximumY: mainWindow.height - glassOverlay.height
        // }
    }
}
