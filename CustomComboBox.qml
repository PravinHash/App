import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ComboBox {
    id: customCombo
    width: 180
    height: 40
    font.pixelSize: 14

    model: ListModel {
        ListElement { iconSource: "qrc:/icons/Periscope.png"; text: "Apple"; color: "#e0f7fa" }
        ListElement { iconSource: "qrc:/icons/Dashboard.png"; text: "Banana"; color: "#ffe0b2" }
        ListElement { iconSource: "qrc:/icons/Periscope.png"; text: "Cherry"; color: "#f8bbd0" }
    }

    // Selected item UI (only icon with tooltip on hover)
    contentItem: Item {
        width: customCombo.width
        height: customCombo.height

        Rectangle {
            id: selectedIconRect
            width: 32
            height: 32
            radius: 4
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 8
            color: customCombo.model.get(customCombo.currentIndex).color

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                fillMode: Image.PreserveAspectFit
                source: customCombo.model.get(customCombo.currentIndex).iconSource
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                ToolTip.visible: containsMouse
                ToolTip.text: customCombo.model.get(customCombo.currentIndex).text
                ToolTip.delay: 500
            }
        }
    }

    // Dropdown arrow indicator
    indicator: Image {
        source: "qrc:/icons/Dashboard.png"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 12
        width: 14
        height: 14
    }

    // Dropdown item view with different background colors
    delegate: ItemDelegate {
        width: customCombo.width
        height: 46   // Increased height slightly to accommodate spacing
        padding: 6

        background: Rectangle {
            color: highlighted ? Qt.darker(model.color, 1.1) : model.color
            radius: 4
        }

        contentItem: ColumnLayout {
            spacing: 6  // Space between delegates
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 4
            anchors.bottomMargin: 4

            RowLayout {
                spacing: 10
                Layout.fillWidth: true

                Image {
                    source: model.iconSource
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    fillMode: Image.PreserveAspectFit
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: model.text
                    color: "#202020"
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }

    // ComboBox background
    background: Rectangle {
        color: "white"
        border.color: "#b0b0b0"
        radius: 6
    }
}
