import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    id: root

    default property alias container: grid.children

    readonly property real maxItemWidth: {
        var maxWidth = 0
        for (var i = 0; i < grid.children.length; i++) {
            maxWidth = Math.max(grid.children[i].width, maxWidth)
        }

        return maxWidth
    }

    property alias spacing: grid.spacing

    width: implicitWidth
    height: implicitHeight
    implicitWidth: parent.width
    implicitHeight: grid.implicitHeight

    Grid {
        id: grid

        anchors.horizontalCenter: parent.horizontalCenter
        width: columns * (root.maxItemWidth + spacing) - spacing
        columns: Math.floor((parent.width + spacing) / (root.maxItemWidth + spacing))
        spacing: Theme.paddingSmall
    
        Component.onCompleted: {
            var maxHeight = 0
            for (var i = 0; i < children.length; i++) {
                maxHeight = Math.max(maxHeight, children[i].implicitHeight)
            }

            for (var i = 0; i < children.length; i++) {
                children[i].height = maxHeight
            }
        }
    }
}
