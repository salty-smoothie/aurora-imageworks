import QtQuick 2.6
import Sailfish.Silica 1.0
import Aurora.Controls 1.0
import QtGraphicalEffects 1.0

Page {
    allowedOrientations: Orientation.All

    AppBar {
        id: appBar

        //% "About"
        headerText: qsTrId("about-page-app-bar-title")

        AppBarSpacer { }

        AppBarButton {
            text: "v1.3.1"

            onClicked: {
                Clipboard.text = text
                //% "Version info copied to clipboard"
                Notices.show(qsTrId("about-page-version-copy-notice"), Notice.Short, Notice.Bottom)
            }
        }
    }

    SilicaFlickable {
        anchors {
            fill: parent
            topMargin: appBar.height
        }

        contentHeight: column.height
        topMargin: Theme.paddingLarge
        bottomMargin: Theme.paddingLarge

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.horizontalPageMargin
                rightMargin: Theme.horizontalPageMargin
            }

            height: childrenRect.height
            spacing: Theme.paddingLarge

            Image {
                id: icon

                anchors.horizontalCenter: parent.horizontalCenter
                width: Theme.dp(128)
                height: width
                source: Qt.resolvedUrl("../symbols/app-icon.png")

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: icon.width
                        height: icon.height
                        radius: Theme.paddingLarge
                    }
                }
            }

            Label {
                width: parent.width
                text: "Imageworks"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                
                font {
                    pixelSize: Theme.fontSizeLarge
                    weight: Font.DemiBold
                }
            }

            Label {
                width: parent.width
                //% "Feature-rich image editing application for Aurora OS based on Python Pillow library."
                text: qsTrId("about-page-app-description")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                //% "Imageworks was originally developed for Sailfish OS and then ported to Aurora OS by Smooth-E."
                text: qsTrId("about-page-port-notice")
                horizontalAlignment: Text.AlignHCenter
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                //% "Imageworks is free software, distributed under the terms of GNU GPL v3."
                text: qsTrId("about-page-license-notice")
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap

                text: "Copyright © 2020 Tobias Planitzer"
                      + "\nCopyright © 2021-2022 Mark Washeim"
                      + "\nCopyright © 2026 Smooth-E"
            }

            Row {
                width: parent.width

                Button {
                    width: (parent.width - Theme.paddingLarge) / 2
                    text: qsTrId("View source")

                    onClicked: {
                        if (mouse.button === Qt.LeftButton) {
                            Qt.openUrlExternally("https://github.com/salty-smoothie/aurora-imageworks")
                        }
                    }
                }

                Item {
                    width: Theme.paddingLarge
                    height: 1
                }

                Button {
                    width: (parent.width - Theme.paddingLarge) / 2
                    //% "Donate"
                    text: qsTrId("about-page-button-donate")

                    onClicked: {
                        if (mouse.button === Qt.LeftButton) {
                            Qt.openUrlExternally("https://boosty.to/smooth-e/donate")
                        }
                    }
                }
            }
        }
    }
}
