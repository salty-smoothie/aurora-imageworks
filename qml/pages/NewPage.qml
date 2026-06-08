import QtQuick 2.6
import Sailfish.Silica 1.0
import Aurora.Controls 1.0
import io.thp.pyotherside 1.5

import "../components"

Page {
    id: page

    // values transmitted from FirstPage.qml
    property var tempImageFolderPath
    property var myColors
    property var maxScalePixels
    property int copyPasteImageWidth
    property int copyPasteImageHeight

    // variables for saving
    property var fileName : "empty.tmp.png"
    property var newImageSizeX
    property var newImageSizeY
    property var paintToolColor : "white"

    Component.onCompleted: {
        newImageSizeY = page.width.toString()
        newImageSizeX = page.height.toString()
    }


    Python {
        id: py

        function createNewImageFunction() {
            var savePath = tempImageFolderPath + fileName
            call("graphx.createNewFunction", [ savePath, idNewImageWidth.text, idNewImageHeight.text, paintToolColor ])
        }

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../python'))
            importModule('graphx', function() { })

            setHandler('fileIsSaved', function() {
                idNewImageButtonRunningIndicator.running = false
                idNewImageButton.enabled = true
                pageStack.pop()
            });
        }

        onError: console.log('python error: ' + traceback);
        onReceived: console.log('got message from python: ' + data);
    } // end Python

    AppBar {
        id: appBar

        //% "Create image"
        headerText: qsTrId("new-page-header")
    }

    SilicaFlickable {
        id: listView

        anchors {
            fill: parent
            topMargin: appBar.height
        }

        contentHeight: columnSaveAs.height
        
        VerticalScrollDecorator { }

        Column {
            id: columnSaveAs

            width: page.width

            Row {
                width: parent.width

                Row {
                    width: parent.width / 6 * 5
                    height: Theme.itemSizeSmall
                    TextField {
                        id: idNewImageWidth
                        width: parent.width / 5*1.5
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: Theme.paddingLarge
                        text: newImageSizeX
                        //% "Width"
                        label: qsTrId("new-page-textfield-width")
                        color: Theme.highlightColor
                        inputMethodHints: Qt.ImhDigitsOnly
                        font.pixelSize: Theme.fontSizeExtraSmall
                        validator: IntValidator { bottom: 1; top: maxScalePixels }
                        EnterKey.onClicked: idNewImageWidth.focus = false
                    }
                    IconButton {
                        id: idPaintOrientationPicker
                        width: parent.width/5*0.5
                        height: Theme.itemSizeSmall
                        icon.source: "image://theme/icon-m-transfer?" //icon-s-retweet?"
                        icon.scale: 0.75 //1.32
                        icon.color: Theme.secondaryHighlightColor
                        icon.rotation: 90
                        onClicked: {
                            var oldWidth = idNewImageWidth.text
                            var oldHeight = idNewImageHeight.text
                            idNewImageWidth.text = oldHeight
                            idNewImageHeight.text = oldWidth
                        }
                    }
                    TextField {
                        id: idNewImageHeight
                        width: parent.width / 5*1.5
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: Theme.paddingLarge
                        text: newImageSizeY
                        //% "Height"
                        label: qsTrId("new-page-textfield-height")
                        horizontalAlignment: Text.AlignRight
                        color: Theme.highlightColor
                        inputMethodHints: Qt.ImhDigitsOnly
                        font.pixelSize: Theme.fontSizeExtraSmall
                        validator: IntValidator { bottom: 1; top: maxScalePixels }
                        EnterKey.onClicked: idNewImageHeight.focus = false
                    }
                    IconButton {
                        id: idPaintColorPicker
                        width: parent.width/5*1.5
                        height: Theme.itemSizeSmall
                        icon.source: "image://theme/icon-s-group-chat?"
                        icon.color: paintToolColor
                        icon.scale: 2//1.32
                        onClicked: {
                            var page = pageStack.push("Sailfish.Silica.ColorPickerPage", { "colors" : myColors})
                            page.colorClicked.connect(function(color) {
                                paintToolColor = color.toString()
                                pageStack.pop()
                            })
                        }
                        Label {
                            horizontalAlignment: Text.AlignHCenter
                            //% "Color"
                            text: qsTrId("new-page-button-color")
                            color: Theme.secondaryHighlightColor
                            font.pixelSize: Theme.fontSizeSmall
                            anchors {
                                top: parent.bottom
                                topMargin: -Theme.paddingMedium * 1.05
                                horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                IconButton {
                    id: idNewImageButton
                    visible: ( idNewImageWidth.text.length > 0 && idNewImageHeight.text.length > 0 ) ? true : false
                    width: parent.width / 6
                    height: Theme.itemSizeSmall
                    icon.source: "../symbols/icon-m-apply.svg"
                    icon.width: Theme.iconSizeMedium
                    icon.height: Theme.iconSizeMedium
                    onClicked: {
                        idNewImageButtonRunningIndicator.running = true
                        idNewImageButton.enabled = false
                        py.createNewImageFunction()
                    }
                    BusyIndicator {
                        id: idNewImageButtonRunningIndicator
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        size: BusyIndicatorSize.Medium
                    }
                }
            } // end row save filename

            Item {
                width: 1
                height: Theme.paddingLarge
            }

            SectionHeader {
                //% "Presets"
                text: qsTrId("new-page-section-presets")
                horizontalAlignment: Text.AlignLeft
            }

            EvenGrid {
                id: grid

                function setResolution(width, height) {
                    idNewImageWidth.text = width
                    idNewImageHeight.text = height
                }

                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }

                LabelledButton {
                    enabled: page.copyPasteImageWidth > 0 && page.copyPasteImageHeight > 0
                    iconSource: "../symbols/icon-m-resize.svg"
                    //% "From clipboard"
                    text: qsTrId("new-page-preset-from-clipboard")

                    onClicked: grid.setResolution(page.copyPasteImageWidth, page.copyPasteImageHeight)
                }

                LabelledButton {
                    iconSource: "../symbols/icon-m-resize.svg"
                    //% "Screen resolution"
                    text: qsTrId("new-page-preset-screen-resolution")

                    onClicked: grid.setResolution(page.width, page.height)
                }

                Repeater {
                    model: ListModel {
                        ListElement {
                            name: "DIN A4 72 dpi"
                            width: 595
                            height: 842
                        }

                        ListElement {
                            name: "DIN A4 150 dpi"
                            width: 1240
                            height: 1754
                        }

                        ListElement {
                            name: "DIN A4 300 dpi"
                            width: 2480
                            height: 3508
                        }

                        ListElement {
                            name: "XGA"
                            width: 1024
                            height: 768
                        }

                        ListElement {
                            name: "WXGA"
                            width: 1366
                            height: 768
                        }

                        ListElement {
                            name: "WXGA+"
                            width: 1440
                            height: 900
                        }

                        ListElement {
                            name: "Full HD"
                            width: 1920
                            height: 1080
                        }

                        ListElement {
                            name: "4k"
                            width: 4096
                            height: 2160
                        }
                    }

                    delegate: LabelledButton {
                        icon.source: "../symbols/icon-m-resize.svg"
                        text: model.name

                        onClicked: grid.setResolution(model.width, model.height)
                    }
                }
            }
        } // end Column
    } // end Silica Flickable
}
