import QtQuick 2.6
import Sailfish.Silica 1.0

Column {
    id: root

    readonly property bool croppingModeCrop: cropModeSelector.currentIndex === 0

    ComboBox {
        id: cropModeSelector

        width: parent.width
        label: qsTr("Cropping mode")
        rightMargin: Theme.horizontalPageMargin + modeIcon.width + Theme.paddingLarge

        menu: ContextMenu {
            MenuItem {
                text: qsTr("Cropping")
            }

            MenuItem {
                text: qsTr("Skewing")
            }
        }

        Icon {
            id: modeIcon

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }

            width: Theme.itemSizeExtraSmall
            height: width
            source: "../symbols/icon-m-cut.svg"
            opacity: root.croppingModeCrop ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                FadeAnimation { }
            }
        }

        Icon {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }

            width: Theme.itemSizeExtraSmall
            height: width
            source: "../symbols/icon-m-transform.svg"
            opacity: root.croppingModeCrop ? 0 : 1
            visible: opacity > 0

            Behavior on opacity {
                FadeAnimation { }
            }
        }
    }

    Item {
        width: parent.width
        height: Math.max(aspectRatioSelector.height, skewModeSelector.height)

        ComboBox {
            id: aspectRatioSelector

            width: parent.width
            opacity: root.croppingModeCrop ? 1 : 0
            visible: opacity > 0

            label: qsTr("Aspect ratio")

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Free crop")
                }

                MenuItem {
                    text: qsTr("Original")
                }

                MenuItem {
                    text: qsTr("Manual")
                }

                MenuItem {
                    text: qsTr("DIN landscape")
                }

                MenuItem {
                    text: qsTr("DIN portrait")
                }

                MenuItem {
                    text: "4:3"
                }

                MenuItem {
                    text: "16:10"
                }

                MenuItem {
                    text: "16:9"
                }

                MenuItem {
                    text: "21:9"
                }

                MenuItem {
                    text: qsTr("Square")
                }

                MenuItem {
                    text: "3:4"
                }

                MenuItem {
                    text: "1:2"
                }

                MenuItem {
                    text: qsTr("Pixels")
                }
            }

            Behavior on opacity {
                FadeAnimation { }
            }
        }

        ComboBox {
            id: skewModeSelector

            width: parent.width
            opacity: root.croppingModeCrop ? 0 : 1
            visible: opacity > 0
            label: qsTr("Mode")

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Stretch to edges")
                }

                MenuItem {
                    text: qsTr("Fold from edges")
                }
            }

            Behavior on opacity {
                FadeAnimation { }
            }
        }
    }

    Item {
        width: 1
        height: Theme.paddingLarge
    }

    Button {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }

        text: qsTr("Apply")
    }
}
