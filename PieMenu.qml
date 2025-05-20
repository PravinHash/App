import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: pieMenu
    width: 300
    height: 300
    color: "transparent"

    property var menuItems: []
    property int menuCount: menuItems.length
    property real innerRadius: 60
    property real outerRadius: 120
    property real angleMargin: Math.PI / 90
    property int hoveredIndex: -1
    property int pressedIndex: -1

    signal menuClicked(int index, var meta)

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var centerX = width / 2
            var centerY = height / 2
            var angleStep = 2 * Math.PI / menuCount
            var margin = angleMargin
            var angleOffset = -Math.PI / 2

            for (var i = 0; i < menuCount; ++i) {
                var startAngle = i * angleStep + margin / 2 + angleOffset
                var endAngle = (i + 1) * angleStep - margin / 2 + angleOffset

                var midRadius = (innerRadius + outerRadius) / 2
                var startX = centerX + Math.cos(startAngle) * midRadius
                var startY = centerY + Math.sin(startAngle) * midRadius
                var endX = centerX + Math.cos(endAngle) * midRadius
                var endY = centerY + Math.sin(endAngle) * midRadius

                var grad = ctx.createLinearGradient(startX, startY, endX, endY)
                grad.addColorStop(0, "red")        // Start side
                grad.addColorStop(0.5, "white")    // Middle
                grad.addColorStop(1, "blue")       // End side

                ctx.fillStyle = (i === pressedIndex) ? "#aaa" :
                                (i === hoveredIndex) ? "#888" : grad

                ctx.beginPath()
                ctx.moveTo(centerX + Math.cos(startAngle) * innerRadius,
                           centerY + Math.sin(startAngle) * innerRadius)
                ctx.arc(centerX, centerY, outerRadius, startAngle, endAngle)
                ctx.lineTo(centerX + Math.cos(endAngle) * innerRadius,
                           centerY + Math.sin(endAngle) * innerRadius)
                ctx.arc(centerX, centerY, innerRadius, endAngle, startAngle, true)
                ctx.closePath()

                ctx.fill()
                ctx.lineWidth = 2
                ctx.strokeStyle = "#fff"
                ctx.stroke()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        property real angleOffset: -Math.PI / 2

        onClicked:(mouse)=> {
            var idx = getIndex(mouse.x, mouse.y)
            if (idx >= 0) {
                pieMenu.menuClicked(idx, menuItems[idx].meta)
                if (typeof menuItems[idx].onClick === "function") {
                    menuItems[idx].onClick()
                }
            }
        }

        onPressed: (mouse) => {
            pressedIndex = getIndex(mouse.x, mouse.y)
            canvas.requestPaint()
        }

        onReleased: () => {
            pressedIndex = -1
            canvas.requestPaint()
        }

        onPositionChanged: (mouse) => {
            hoveredIndex = getIndex(mouse.x, mouse.y)
            canvas.requestPaint()
        }

        onExited: () => {
            hoveredIndex = -1
            canvas.requestPaint()
        }

        function getIndex(x, y) {
            var dx = x - pieMenu.width / 2
            var dy = y - pieMenu.height / 2
            var dist = Math.sqrt(dx * dx + dy * dy)
            if (dist < pieMenu.innerRadius || dist > pieMenu.outerRadius)
                return -1
            var angle = Math.atan2(dy, dx)
            if (angle < 0)
                angle += 2 * Math.PI
            angle = (angle - angleOffset + 2 * Math.PI) % (2 * Math.PI)
            return Math.floor(angle / (2 * Math.PI / menuCount))
        }
    }

    Repeater {
        model: menuItems
        delegate: Item {
            width: 45
            height: 45
            property real angle: 2 * Math.PI / pieMenu.menuCount * (index + 0.5) - Math.PI / 2
            property var icon: modelData.icon

            x: pieMenu.width / 2 + Math.cos(angle) * ((pieMenu.innerRadius + pieMenu.outerRadius) / 2) - width / 2
            y: pieMenu.height / 2 + Math.sin(angle) * ((pieMenu.innerRadius + pieMenu.outerRadius) / 2) - height / 2

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                border.color: "grey"
                border.width: 2
                color: "transparent"

                Image {
                    source: icon
                    anchors.centerIn: parent
                    width: 28
                    height: 28
                }
            }
        }
    }

    Rectangle {
        id: centerHole
        width: pieMenu.innerRadius * 2
        height: pieMenu.innerRadius * 2
        anchors.centerIn: parent
        radius: width / 2
        color: "transparent"
        border.color: "#ccc"
        border.width: 2

        Text {
            text: "Menu"
            anchors.centerIn: parent
            font.pixelSize: 22
            color: "#ccc"
        }
    }
}
