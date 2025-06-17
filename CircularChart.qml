import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import QtQuick.Controls.Material 2.15

Rectangle {
    id: radialChart
    visible: true
    width: 900
    height: 800
    color: "#121212"

    property int minRange: 10
    property int maxRange: 300
    property int step: 10
    property int currentMaxRange: 100
    property bool gridVisible: true
    property bool showAngleLabels: true
    property int heading: 40
    property bool headingTop: false
    property bool baffleVisible: true

    property int baffleStartAngle: 130
    property int baffleEndAngle: 210

    property color textColor: "#e0e0e0"
    property color buttonColor: "#1e88e5"
    property color gridLineColor: "#666"

    //Bearing Line and sRM

    property bool radiiInitialized: false
    property bool isFirstCircleLocked: false
    property bool isSecondCircleLocked: false
    property real firstCircleRadius: 0
    property real secondCircleRadius: 0



    property var dataPoints: [
        {
            id: "MN11", angle: 0, value: 100, category: "high",
            vector: [ [10, 110], [20, 120], [30, 130] ],
            trails: [ [350, 90], [340, 80], [330, 70] ]
        },
        {
            id: "MN12", angle: 45, value: 80, category: "medium",
            vector: [[45, 80], [50, 85], [55, 90], [60, 95] ],
            trails: [ [40, 75], [35, 70], [30, 65] ]
        },
        {
            id: "MN13", angle: 90, value: 100, category: "low",
            vector: [[20, 80], [50, 85], [105, 90], [130, 150] ],
            trails: [ [40, 75], [35, 70], [30, 65] ]
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: "Zoom In"
                background: Rectangle { color: buttonColor }
                onClicked: {
                    if (currentMaxRange > minRange) {
                        currentMaxRange -= step
                        valueAxis.max = currentMaxRange
                        pointLayer.forceUpdate()
                        canvas.requestPaint()
                        baffleCanvas.requestPaint()
                    }
                }
            }

            Button {
                text: "Zoom Out"
                background: Rectangle { color: buttonColor }
                onClicked: {
                    if (currentMaxRange < maxRange) {
                        currentMaxRange += step
                        valueAxis.max = currentMaxRange
                        pointLayer.forceUpdate()
                        canvas.requestPaint()
                        baffleCanvas.requestPaint()
                    }
                }
            }

            Button {
                text: gridVisible ? "Hide Grid Lines" : "Show Grid Lines"
                background: Rectangle { color: buttonColor }
                onClicked: {
                    gridVisible = !radialChart.gridVisible
                    angleAxis.gridVisible = gridVisible
                    valueAxis.gridVisible = gridVisible
                    canvas.requestPaint()
                    baffleCanvas.requestPaint()
                }
            }

            Button {
                text: showAngleLabels ? "Hide Angle Labels" : "Show Angle Labels"
                background: Rectangle { color: buttonColor }
                onClicked: {
                    showAngleLabels = !showAngleLabels
                    canvas.requestPaint()
                    baffleCanvas.requestPaint()
                }
            }

            Button {
                text: headingTop ? "North Top" : "Heading Top"
                background: Rectangle { color: buttonColor }
                onClicked: {
                    headingTop = !headingTop
                    pointLayer.forceUpdate()
                    canvas.requestPaint()
                    baffleCanvas.requestPaint()
                }
            }

            Button {
                text: baffleVisible ? "Hide Baffle" : "Show Baffle"
                background: Rectangle { color: buttonColor }
                onClicked: {
                    baffleVisible = !baffleVisible
                    baffleCanvas.requestPaint()
                }
            }

            Label {
                text: "Range: 0 - " + currentMaxRange
                color: radialChart.textColor
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.margins: 0
            Layout.margins: 0

            Rectangle{
                anchors.fill: parent
                color: "white"
            }

            PolarChartView {
                id: polarChart
                anchors.fill: parent
                antialiasing: true
                legend.visible: false
                backgroundColor: "#1C1C1C"
                anchors.margins: -15

                ValueAxis {
                    id: valueAxis
                    min: 0
                    max: currentMaxRange
                    tickCount: 6
                    labelsVisible: false
                    visible: false
                }

                Item {
                    id: pointLayer
                    anchors.fill: parent

                    function polarToPixel(angleDeg, value) {
                        const plotRect = polarChart.plotArea;
                        const centerX = plotRect.x + plotRect.width / 2;
                        const centerY = plotRect.y + plotRect.height / 2;
                        const radiusMax = Math.min(plotRect.width, plotRect.height) / 2;
                        const baseRotation = headingTop ? heading : 0;
                        const angleRad = (angleDeg - 90 - baseRotation) * Math.PI / 180;
                        const normalizedRadius = value / valueAxis.max;
                        const radius = normalizedRadius * radiusMax;
                        return {
                            x: centerX + radius * Math.cos(angleRad),
                            y: centerY + radius * Math.sin(angleRad)
                        };
                    }

                    function forceUpdate() {
                        pointRepeater.model = null;
                        pointRepeater.model = dataPoints;
                    }

                    // in a JS file or inline before onPaint:
                    function metersToLatOffset(meters) {
                        return meters / 111320.0;
                    }
                    function metersToLonOffset(meters, latitude) {
                        return meters / (111320.0 * Math.cos(latitude * Math.PI / 180));
                    }



                    Repeater {
                        id: pointRepeater
                        model: dataPoints
                        delegate: Item {
                            width: 45
                            height: 45
                            property var pos: pointLayer.polarToPixel(modelData.angle, modelData.value)

                            property string iconSource: {
                                switch (modelData.category) {
                                case "high": return "qrc:/icons/Dashboard.png"
                                case "medium": return "qrc:/icons/Periscope.png"
                                case "low": return "qrc:/icons/Periscope.png"
                                default: return "qrc:/icons/Periscope.png"
                                }
                            }

                            ToolTip.visible: pointLayer.hovered
                            ToolTip.text: "Angle: " + modelData.angle + "°, Value: " + modelData.value

                            Image {
                                width: 20
                                height: 20
                                source: iconSource
                                x: pos.x - width / 2
                                y: pos.y - height / 2

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: pointLayer.hovered = true
                                    onExited: pointLayer.hovered = false
                                    onClicked: console.log("Clicked on")
                                }
                            }
                        }
                    }

                    // Main canvas (grid and labels)
                    Canvas {
                        id: canvas
                        anchors.fill: parent
                        z: -999

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            const plot = polarChart.plotArea;
                            const cx = plot.x + plot.width / 2;
                            const cy = plot.y + plot.height / 2;
                            // const r = Math.min(plot.width, plot.height) / 2 + 10;
                            const r = Math.min(plot.width, plot.height) / 2 + 10;

                            const baseRotation = headingTop ? heading : 0;
                            const ringCount = 4;
                            const colors = [
                                ["#121212", "#333333"],
                                ["#121212", "#2a2a2a"],
                                ["#121212", "#202020"],
                                ["#121212", "#2a2a2a"]
                            ];

                            /*
                              Grid Lines
                            */
                            // -- DRAW LAT/LON GRID --
                            ctx.strokeStyle = "#555";
                            ctx.lineWidth = 2;
                            ctx.fillStyle = "red";
                            ctx.font = "10px sans-serif";
                            ctx.textAlign = "left";
                            ctx.textBaseline = "top";

                            // Center of the screen in lat/lon
                            const lat0 = radialChart.centerLatitude;
                            const lon0 = radialChart.centerLongitude;
                            const gridSize = radialChart.metersPerGrid;

                            // Convert radius in px to max offset in meters
                            const maxOffsetM = r;
                            const gridSteps = Math.floor(r / gridSize);

                            // Horizontal lines (latitude)
                            for (let i = -gridSteps; i <= gridSteps; i++) {
                                const offsetPixels = (i * gridSize / valueAxis.max) * r;
                                const y = cy + offsetPixels;
                                if (y < plot.y || y > plot.y + plot.height) continue;

                                const latOffset = -i * gridSize;
                                const lat = lat0 + pointLayer.metersToLatOffset(latOffset);

                                ctx.beginPath();
                                ctx.moveTo(plot.x, y);
                                ctx.lineTo(plot.x + plot.width, y);
                                ctx.stroke();

                                ctx.fillText(lat.toFixed(5) + "°N", plot.x + 4, y + 2);
                            }

                            // Vertical lines (longitude)
                            for (let j = -gridSteps; j <= gridSteps; j++) {
                                const offsetPixels = (j * gridSize / valueAxis.max) * r;
                                const x = cx + offsetPixels;
                                if (x < plot.x || x > plot.x + plot.width) continue;

                                const lonOffset = j * gridSize;
                                const lon = lon0 + pointLayer.metersToLonOffset(lonOffset, lat0);

                                ctx.beginPath();
                                ctx.moveTo(x, plot.y);
                                ctx.lineTo(x, plot.y + plot.height);
                                ctx.stroke();

                                ctx.fillText(lon.toFixed(5) + "°E", x + 2, plot.y + 2);
                            }

                            /**************************************************************/

                            function drawSpline(points, color, lineWidth) {
                                if (points.length < 2) return;
                                const pts = points.map(p => pointLayer.polarToPixel(p[0], p[1]));

                                ctx.beginPath();
                                ctx.strokeStyle = color;
                                ctx.lineWidth = lineWidth;

                                ctx.moveTo(pts[0].x, pts[0].y);
                                for (let i = 1; i < pts.length - 1; i++) {
                                    const xc = (pts[i].x + pts[i + 1].x) / 2;
                                    const yc = (pts[i].y + pts[i + 1].y) / 2;
                                    ctx.quadraticCurveTo(pts[i].x, pts[i].y, xc, yc);
                                }
                                ctx.lineTo(pts[pts.length - 1].x, pts[pts.length - 1].y);
                                ctx.stroke();
                            }

                            function drawTriangleMarker(angleDeg, innerRadius, outerRadius, color) {
                                const angleRad = (angleDeg - 90 - baseRotation) * Math.PI / 180;

                                const xTip = cx + innerRadius * Math.cos(angleRad);
                                const yTip = cy + innerRadius * Math.sin(angleRad);

                                const sideOffset = 8;
                                const perpendicular = angleRad + Math.PI / 2;

                                const xLeft = cx + outerRadius * Math.cos(angleRad) + sideOffset * Math.cos(perpendicular);
                                const yLeft = cy + outerRadius * Math.sin(angleRad) + sideOffset * Math.sin(perpendicular);
                                const xRight = cx + outerRadius * Math.cos(angleRad) - sideOffset * Math.cos(perpendicular);
                                const yRight = cy + outerRadius * Math.sin(angleRad) - sideOffset * Math.sin(perpendicular);

                                ctx.beginPath();
                                ctx.moveTo(xTip, yTip);
                                ctx.lineTo(xLeft, yLeft);
                                ctx.lineTo(xRight, yRight);
                                ctx.closePath();
                                ctx.fillStyle = color;
                                ctx.fill();
                            }

                            function drawCircle(px, py, radius, color, dash, lWidth) {
                                // Draw circle border
                                ctx.beginPath();
                                ctx.setLineDash(dash); // 4px dash, 2px gap
                                ctx.strokeStyle = color; // Border color
                                ctx.lineWidth = lWidth;
                                ctx.arc(px, py, radius, 0, 2 * Math.PI);
                                ctx.stroke();
                            }

                            if (radialChart.gridVisible) {
                                for (let i = ringCount; i >= 1; --i) {
                                    const outerRadius = (i / ringCount) * r;
                                    const innerRadius = ((i - 1) / ringCount) * r;

                                    ctx.beginPath();
                                    ctx.arc(cx, cy, outerRadius, 0, 2 * Math.PI);
                                    ctx.arc(cx, cy, innerRadius, 0, 2 * Math.PI, true);
                                    ctx.closePath();

                                    if (i === ringCount) {
                                        // Gradient fill only for outermost ring
                                        const gradient = ctx.createRadialGradient(cx, cy, innerRadius, cx, cy, outerRadius);
                                        gradient.addColorStop(0, "rgba(0, 0, 0, 0)");
                                        gradient.addColorStop(0.5,"rgba(0, 0, 0, 0)");
                                        gradient.addColorStop(1, "rgba(255, 255, 255, 0.08)");
                                        ctx.fillStyle = gradient;
                                        ctx.fill();
                                    }

                                    drawCircle(cx, cy, outerRadius, "#444", [4, 4], 1);
                                }

                                // Reset dash style
                                ctx.setLineDash([]);

                                ctx.fillStyle = textColor;
                                ctx.font = "10px sans-serif";
                                ctx.textAlign = "left";

                                for (let i = 1; i <= ringCount; ++i) {
                                    const radius = (i / ringCount) * r;
                                    const value = Math.round((i / ringCount) * valueAxis.max);
                                    ctx.fillText(value.toString(), cx + radius + 5, cy);
                                }
                            }


                            if (!radialChart.radiiInitialized) {
                                radialChart.firstCircleRadius = 2 * r / 3;
                                radialChart.secondCircleRadius = r / 3;
                                radialChart.radiiInitialized = true;
                            }

                            if (showAngleLabels) {
                                const baseRotation = headingTop ? heading : 0;

                                ctx.strokeStyle = "#666";
                                ctx.lineWidth = 1;
                                ctx.fillStyle = textColor;
                                ctx.font = "10px sans-serif";
                                ctx.textAlign = "center";
                                ctx.textBaseline = "middle";

                                for (let i = 0; i < 360; i += 2) {
                                    const angle = (i - 90 - baseRotation) * Math.PI / 180;
                                    const isMajor = i % 10 === 0;
                                    const offset = isMajor ? 16 : 6;

                                    const x1 = cx + (r - 45 - offset) * Math.cos(angle);
                                    const y1 = cy + (r - 45 - offset) * Math.sin(angle);
                                    const x2 = cx + (r - 45) * Math.cos(angle);
                                    const y2 = cy + (r - 45) * Math.sin(angle);

                                    ctx.beginPath();
                                    ctx.moveTo(x1, y1);
                                    ctx.lineTo(x2, y2);
                                    ctx.stroke();

                                    if (isMajor) {
                                        const labelRadius = r - 30;
                                        const labelX = cx + labelRadius * Math.cos(angle);
                                        const labelY = cy + labelRadius * Math.sin(angle);
                                        ctx.fillText(i.toString() + "°", labelX, labelY);
                                    }
                                }
                            }

                            for (let i = 0; i < radialChart.dataPoints.length; i++) {
                                const point = radialChart.dataPoints[i];

                                if (point.trails && point.trails.length >= 2)
                                    drawSpline(point.trails, "#00BCD4", 2); // Cyan trail

                                if (point.vector && point.vector.length >= 2)
                                    drawSpline(point.vector, "#FF9800", 2); // Orange vector
                            }

                            if (radialChart.gridVisible || showAngleLabels) {
                                const minorTickOuter = r - 40;
                                const minorTickInner = minorTickOuter - 10;
                                drawTriangleMarker(heading, minorTickInner, minorTickOuter, "#FFFFFF");
                            }

                            // drawCircle(cx, cy,r*2/3, "#994040", [4, 4], 3)
                            // drawCircle(cx, cy,r/3, "#994040", [4, 4], 3)

                            if (radialChart.firstCircleRadius > 0)
                                drawCircle(cx, cy, radialChart.firstCircleRadius, "#994040", [4, 4], 3);

                            if (radialChart.secondCircleRadius > 0)
                                drawCircle(cx, cy, radialChart.secondCircleRadius, "#FFFFFF", [4, 4], 3);

                        }

                        Connections {
                            target: polarChart
                            onPlotAreaChanged: canvas.requestPaint()
                        }
                        Connections {
                            target: radialChart
                            onGridVisibleChanged: canvas.requestPaint()
                            onShowAngleLabelsChanged: canvas.requestPaint()
                        }
                        Component.onCompleted: {
                            canvas.requestPaint()
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onPositionChanged: {
                                const dx = mouse.x - canvas.width / 2;
                                const dy = mouse.y - canvas.height / 2;
                                const dist = Math.sqrt(dx * dx + dy * dy);

                                if (!radialChart.isFirstCircleLocked) {
                                    radialChart.firstCircleRadius = dist;
                                } else if (!radialChart.isSecondCircleLocked) {
                                    radialChart.secondCircleRadius = dist;
                                }

                                canvas.requestPaint();
                            }

                            onClicked: {
                                if (!radialChart.isFirstCircleLocked) {
                                    radialChart.isFirstCircleLocked = true;
                                } else if (!radialChart.isSecondCircleLocked) {
                                    radialChart.isSecondCircleLocked = true;
                                }
                            }
                        }

                    }

                    // 🔺 Baffle Canvas
                    Canvas {
                        id: baffleCanvas
                        anchors.fill: parent
                        antialiasing: true

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            ctx.clearRect(0, 0, width, height);
                            if (!radialChart.baffleVisible)
                                return;


                            const cx = width / 2;
                            const cy = height / 2;
                            const screenRadius = Math.sqrt(width * width + height * height);  // reach full screen

                            const baseRotation = headingTop ? heading : 0;
                            const sectorCount = 4;
                            const angleStart = baffleStartAngle;
                            const angleEnd = baffleEndAngle;
                            const delta = (angleEnd - angleStart) / sectorCount;

                            const colors = [
                                             "rgba(255, 0, 0, 0.3)",    // red
                                             "rgba(0, 255, 0, 0.3)",    // green
                                             "rgba(0, 0, 255, 0.3)",    // blue
                                             "rgba(255, 255, 0, 0.3)"   // yellow
                                         ];

                            for (let i = 0; i < sectorCount; ++i) {
                                const a1 = (angleStart + i * delta - 90 - baseRotation) * Math.PI / 180;
                                const a2 = (angleStart + (i + 1) * delta - 90 - baseRotation) * Math.PI / 180;

                                const x1 = cx + screenRadius * Math.cos(a1);
                                const y1 = cy + screenRadius * Math.sin(a1);
                                const x2 = cx + screenRadius * Math.cos(a2);
                                const y2 = cy + screenRadius * Math.sin(a2);

                                ctx.fillStyle = colors[i % colors.length];
                                ctx.beginPath();
                                ctx.moveTo(cx, cy);
                                ctx.lineTo(x1, y1);
                                ctx.lineTo(x2, y2);
                                ctx.closePath();
                                ctx.fill();
                            }
                        }

                        Connections {
                            target: polarChart
                            onPlotAreaChanged: baffleCanvas.requestPaint()
                        }
                        Connections {
                            target: radialChart
                            onHeadingTopChanged: baffleCanvas.requestPaint()
                            onHeadingChanged: baffleCanvas.requestPaint()
                        }
                        Component.onCompleted: baffleCanvas.requestPaint()
                    }
                }
            }
        }
    }
}
