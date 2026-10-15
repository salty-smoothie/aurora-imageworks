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
    property string paintToolColor : "white"

    property bool _busy

    Component.onCompleted: {
        newImageSizeY = page.width.toString()
        newImageSizeX = page.height.toString()
    }


    Python {
        id: py

        function createNewImageFunction() {
            var savePath = tempImageFolderPath + fileName
            call("new_image.create_image", [ savePath, idNewImageWidth.text, idNewImageHeight.text, paintToolColor ])
        }

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../python'))
            importModule('new_image', function() { })
            setHandler('fileIsSaved', function() { pageStack.pop() });
        }

        onError: console.log('python error: ' + traceback);
        onReceived: console.log('got message from python: ' + data);
    } // end Python

    AppBar {
        id: appBar

        //% "Create image"
        headerText: qsTrId("new-page-header")

        AppBarSpacer { }

        AppBarButton {
            enabled: !page._busy
            icon.source: "image://theme/icon-splus-accept"

            onClicked: {
                page._busy = true
                py.createNewImageFunction()
            }
        }
    }

    ExtendedBusyLabel {
        running: page._busy
    }

    SilicaFlickable {
        id: listView

        anchors {
            fill: parent
            topMargin: appBar.height
        }

        contentHeight: columnSaveAs.height
        opacity: page._busy ? 0 : 1

        Behavior on opacity { 
            FadeAnimation { }
        }
        
        VerticalScrollDecorator { }

        Column {
            id: columnSaveAs

            width: page.width

            SectionHeader {
                //% "New image settings"
                text: qsTrId("new-page-section-image-settings")
                horizontalAlignment: Text.AlignLeft
            }

            Row {
                id: dimensionsRow

                readonly property real fieldWidth: (width - switchDimensionsButton.width) / 2

                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }

                height: idNewImageWidth.height + Theme.paddingLarge

                TextField {
                    id: idNewImageWidth

                    anchors.verticalCenter: parent.verticalCenter
                    width: dimensionsRow.fieldWidth
                    text: newImageSizeX
                    //% "Width"
                    label: qsTrId("new-page-textfield-width")                    

                    validator: IntValidator { 
                        bottom: 1
                        top: maxScalePixels 
                    }
                    
                    EnterKey.onClicked: idNewImageWidth.focus = false
                }

                IconButton {
                    id: switchDimensionsButton

                    width: Theme.itemSizeSmall
                    height: width
                    
                    icon {
                        source: "image://theme/icon-m-transfer?"
                        scale: 0.75
                        color: Theme.secondaryHighlightColor
                    }
                    
                    onClicked: {
                        const oldWidth = idNewImageWidth.text
                        const oldHeight = idNewImageHeight.text
                        idNewImageWidth.text = oldHeight
                        idNewImageHeight.text = oldWidth
                    }
                }

                TextField {
                    id: idNewImageHeight

                    anchors.verticalCenter: parent.verticalCenter
                    width: dimensionsRow.fieldWidth
                    text: newImageSizeY
                    //% "Height"
                    label: qsTrId("new-page-textfield-height")
                    horizontalAlignment: Text.AlignRight
                    inputMethodHints: Qt.ImhDigitsOnly
                    
                    validator: IntValidator { 
                        bottom: 1
                        top: maxScalePixels 
                    }

                    EnterKey.onClicked: idNewImageHeight.focus = false
                }
            }

            BackgroundItem {
                width: parent.width
                height: fillColorLabel.height + fillColorDescription.height + Theme.paddingLarge * 2

                onClicked: {
                    const picker = pageStack.push("Sailfish.Silica.ColorPickerPage", { "colors": myColors })
                    picker.colorClicked.connect(function(color) {
                        page.paintToolColor = color
                        pageStack.pop()
                    })
                }

                Label {
                    id: fillColorLabel

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: fillColorPatch.left
                        topMargin: Theme.paddingLarge
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.paddingMedium
                    }

                    //% "Fill color"
                    text: qsTrId("new-page-fill-color-title")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                    wrapMode: Text.WordWrap
                }

                Label {
                    id: fillColorDescription

                    anchors {
                        top: fillColorLabel.bottom
                        left: fillColorLabel.left
                        right: fillColorLabel.right
                    }

                    //% "Select base color for the new image"
                    text: qsTrId("new-page-fill-color-summary")
                    color: parent.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                }

                Rectangle {
                    id: fillColorPatch

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }

                    width: Theme.itemSizeExtraSmall
                    height: width
                    color: page.paintToolColor
                    radius: Theme.dp(8)
                }
            }

            SectionHeader {
                //% "Resolution presets"
                text: qsTrId("new-page-section-resolution-presets")
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
                    icon.source: "../symbols/icon-m-resize.svg"
                    //% "From clipboard"
                    text: qsTrId("new-page-preset-from-clipboard")

                    onClicked: grid.setResolution(page.copyPasteImageWidth, page.copyPasteImageHeight)
                }

                LabelledButton {
                    icon.source: "../symbols/icon-m-resize.svg"
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
