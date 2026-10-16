import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    id: root

    property bool active

    signal openFromGallery()
    signal openFromFiles()
    signal createNewImage()

    opacity: root.active ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        FadeAnimation { }
    }

    Column {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }

        height: implicitHeight
        spacing: Theme.paddingLarge

        Label {
            width: parent.width
            //% "Welcome to Imageworks!"
            text: qsTrId("welcome-widget-title")
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeHuge
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            width: parent.width
            //% "Open an exisiting image or create a new one to start editing"
            text: qsTrId("welcome-widget-subtitle")
            color: Theme.secondaryColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeLarge
        }

        ButtonLayout {
            width: parent.width

            Button {
                icon.source: "image://theme/icon-splus-image"
                //% "Open from gallery"
                text: qsTrId("welcome-widget-button-gallery")

                onClicked: root.openFromGallery()
            }

            Button {
                icon.source: "image://theme/icon-splus-file-folder"
                //% "Open from files"
                text: qsTrId("welcome-widget-button-files")

                onClicked: root.openFromFiles()
            }

            Button {
                icon.source: "image://theme/icon-splus-new"
                //% "Create new image"
                text: qsTrId("welcome-widget-button-new")

                onClicked: root.createNewImage()
            }
        }
    }
}
