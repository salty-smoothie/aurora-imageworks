import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    readonly property bool imageAvailable: !!app.imageSource

    Column {
        anchors {
            fill: parent
            topMargin: app.coverTopPadding
            leftMargin: Theme.paddingCover
            rightMargin: Theme.paddingCover
        }

        spacing: Theme.paddingSmall
        visible: !cover.imageAvailable

        Behavior on opacity {
            FadeAnimation { }
        }

        Label {
            width: parent.width
            //% "Welcome to Imageworks!"
            text: qsTrId("cover-page-welcome-title")
            wrapMode: Text.WordWrap

            font {
                pixelSize: Theme.fontSizeExtraSmall
                weight: Font.Medium
            }
        }

        Label {
            width: parent.width
            //% "Edit images and create new ones"
            text: qsTrId("cover-page-welcome-subtitle")
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeTiny
            color: Theme.secondaryColor
        }
    }

    Item {
        anchors.fill: parent
        visible: cover.imageAvailable

        Image {
            id: previewImage

            anchors.fill: parent
            source: app.imageSource
            fillMode: Image.PreserveAspectCrop
        }

        OpacityRampEffect {
            sourceItem: previewImage
            direction: OpacityRamp.TopToBottom
        }

        Label {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                bottomMargin: Theme.paddingCover
            }

            height: implicitHeight
            //% "Currently editing"
            text: qsTrId("cover-page-editing-subtitle")
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
