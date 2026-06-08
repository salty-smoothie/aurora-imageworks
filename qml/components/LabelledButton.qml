import QtQuick 2.6
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

BackgroundItem {
    id: root

    readonly property color elementsColor: highlighted
                                           ? Theme.highlightColor
                                           : enabled
                                             ? Theme.primaryColor
                                             : Theme.secondaryColor

    property alias iconSource: icon.source
    property alias text: label.text

    width: implicitWidth
    height: implicitHeight
    implicitWidth: Theme.itemSizeLarge
    implicitHeight: column.height

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: Theme.dp(8)
        }
    }

    Column {
        id: column

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingSmall
            rightMargin: Theme.paddingSmall
        }

        height: implicitHeight
        spacing: Theme.paddingMedium
        topPadding: Theme.paddingSmall
        bottomPadding: Theme.paddingSmall

        Icon {
            id: icon

            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.iconSizeMedium
            height: width
            color: root.elementsColor
        }

        Label {
            id: label

            width: parent.width
            height: implicitHeight
            wrapMode: Text.WordWrap
            opacity: root.enabled ? 1 : Theme.opacityOverlay
            color: root.elementsColor
            font.pixelSize: Theme.fontSizeExtraSmall
            horizontalAlignment: Text.AlignHCenter
        }
    }
}