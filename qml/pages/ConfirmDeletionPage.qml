import QtQuick 2.6
import Sailfish.Silica 1.0
import Aurora.Controls 1.0

Page {
    id: page

    property string filePath
    property var callback

    AppBar {
        id: appBar

        //% "Confirm deletion"
        headerText: qsTrId("confirm-deletion-header")

        AppBarSpacer { }

        AppBarButton {
            icon.source: "image://theme/icon-splus-accept"

            onClicked: {
                page.callback()
                pageStack.pop()
            }
        }
    }

    SilicaFlickable {
        anchors {
            fill: parent
            topMargin: appBar.height
        }

        topMargin: Theme.paddingLarge
        bottomMargin: Theme.paddingLarge
        contentHeight: column.height

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.horizontalPageMargin
                rightMargin: Theme.horizontalPageMargin
            }

            spacing: Theme.paddingLarge

            Label {
                width: parent.width
                //% "Are you sure you want to delete the file and all related temporary files?"
                text: qsTrId("confirm-deletion-title")
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                //% "The original file to be deleted is located here:"
                text: qsTrId("confirm-deletion-subtitle")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                text: page.filePath
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
