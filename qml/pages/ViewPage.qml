import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: imagePage
    property var inputPathPy
    allowedOrientations: Orientation.All

    Rectangle {
        id: root

        anchors.fill: parent
        color: Theme.colorScheme === Theme.LightOnDark ? Theme.darkPrimaryColor : Theme.lightPrimaryColor

        Item {
            id: photoFrame

            width: root.width
            height: root.height

            Image {
                id: image

                anchors.fill: parent
                source: inputPathPy
                fillMode: Image.PreserveAspectFit
                cache: false
            }

            PinchArea {
                anchors.fill: parent

                pinch {
                    target: photoFrame
                    minimumRotation: 0
                    maximumRotation: 0
                    minimumScale: 1
                    maximumScale: 10
                }

                onPinchUpdated: {
                    if(photoFrame.x < dragArea.drag.minimumX) {
                        photoFrame.x = dragArea.drag.minimumX
                    } else if(photoFrame.x > dragArea.drag.maximumX) {
                        photoFrame.x = dragArea.drag.maximumX
                    }

                    if(photoFrame.y < dragArea.drag.minimumY) {
                        photoFrame.y = dragArea.drag.minimumY
                    } else if(photoFrame.y > dragArea.drag.maximumY) {
                        photoFrame.y = dragArea.drag.maximumY
                    }
                }

                MouseArea {
                    id: dragArea
                
                    readonly property real minX: (root.width - (photoFrame.width * photoFrame.scale)) / 2
                    readonly property real minY: (root.height - (photoFrame.height * photoFrame.scale)) / 2

                    hoverEnabled: true
                    anchors.fill: parent

                    drag {
                        target: photoFrame
                        minimumX: minX
                        maximumX: -minX
                        minimumY: minY
                        maximumY: -minY
                    }

                    onDoubleClicked: { //reset size and location of view
                        photoFrame.x = 0
                        photoFrame.y = 0
                        photoFrame.scale = 1
                    }

                    onWheel: {
                        var scaleBefore = photoFrame.scale
                        photoFrame.scale += photoFrame.scale * wheel.angleDelta.y / 120 / 10

                        if(photoFrame.scale < 1) {
                            photoFrame.scale = 1
                        } else if(photoFrame.scale > 4) {
                            photoFrame.scale = 4
                        }

                        // Don't zoom behind border of image
                        if(photoFrame.x < drag.minimumX) {
                            photoFrame.x = drag.minimumX
                        } else if(photoFrame.x > drag.maximumX) {
                            photoFrame.x = drag.maximumX
                        }

                        if(photoFrame.y < drag.minimumY) {
                            photoFrame.y = drag.minimumY
                        } else if(photoFrame.y > drag.maximumY) {
                            photoFrame.y = drag.maximumY
                        }
                    }
                }
            }
        }

        Label {
            id: idZoomLabel

            readonly property real photoScale: photoFrame.scale.toFixed(1)

            anchors {
                top: parent.top
                right: parent.right
                topMargin: Theme.paddingLarge
                rightMargin: Theme.paddingLarge
            }

            text: photoScale + "x"
            opacity: photoScale === 1 ? 0 : 1
            visible: opacity > 0

            Behavior on opacity {
                FadeAnimation { }
            }
            
            Rectangle {
                anchors {
                    fill: parent
                    leftMargin: -Theme.paddingMedium
                    rightMargin: -Theme.paddingMedium
                }
                
                z: -1
                color: Theme.overlayBackgroundColor
                opacity: 0.4
            }
        }
    }
}
