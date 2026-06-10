import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    id: root

    default property alias container: grid.children

    property alias spacing: grid.spacing

    width: implicitWidth
    height: implicitHeight
    implicitWidth: parent.width
    implicitHeight: grid.implicitHeight

    Grid {
        id: grid

        readonly property real maxItemWidth: {
            var maxWidth = 0
            for (var i = 0; i < children.length; i++) {
                maxWidth = Math.max(children[i].width, maxWidth)
            }

            return maxWidth
        }

        width: implicitWidth
        spacing: Theme.paddingMedium
        columns: Math.floor((parent.width + spacing) / (maxItemWidth + spacing))

        Component.onCompleted: {
            var columnWidth = (parent.width + spacing) / columns - spacing
            for (var i = 0; i < children.length; i++) {
                children[i].width = columnWidth
            }

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
