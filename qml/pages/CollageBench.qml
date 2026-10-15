import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Aurora.Controls 1.0
import io.thp.pyotherside 1.5

import "../components"

Page {
    id: page

    // values transmitted from FirstPage.qml
    property var tempImageFolderPath
    property var inputPathPy
    property var inputImageWidth
    property var outputPathPy
    property var filterSourceFolder
    property var previewImageRatio
    property var handleWidth
    property var toolsDrawingColorFrame
    property var opacityEdges
    property var paintToolColor
    property var symbolSourceFolder
    property var previewBaseImagePath

    // values for UI
    property bool blockApply : false
    property var ratioWidthOriginal2Preview : inputImageWidth / idPreviewImage.width
    property var currentCollageType : "lines"
    property bool warningLargeSize : false
    property var warningInputMaxWidth : 4096

    // values for files
    property var allSelectedPaths : ""
    property var randomAngleList : ""
    property var ratioWanted : ""
    property var selectedFilesCounter : 0

    allowedOrientations: Orientation.All

    Component.onCompleted: {
        if (inputImageWidth > warningInputMaxWidth) {
            warningLargeSize = true
            inputImageWidth = warningInputMaxWidth
        }
    }

    Component {
        id: multiImagePickerDialog

        MultiImagePickerDialog {
            onAccepted: {
                allSelectedPaths = ""
                randomAngleList = ""
                var urls = []
                var paths = []

                for (var i = 0; i < selectedContent.count; ++i) {
                    var url = selectedContent.get(i).url
                    var path = decodeURIComponent("/" + (selectedContent.get(i).url).toString()
                                                        .replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,""))
                    urls.push(selectedContent.get(i).url)
                    paths.push(decodeURIComponent("/" + (selectedContent.get(i).url).toString()
                                                        .replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"") ))
                }

                allSelectedPaths = paths.join(",")
                selectedFilesCounter = selectedContent.count
                blockApply = true
                py.createImageMosaic("preview")
            }
        }
    }

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'))
            importModule('graphx', function () { })

            // Handlers = Signals to do something in QML whith received Infos from pyotherside
            setHandler('previewImageCreated', function( previewPath, shuffledPaths, randomAngles ) {
                idPreviewImage.source = "" // Patch: make sure not to get old content ever
                idPreviewImage.source = encodeURI( previewPath )
                allSelectedPaths = shuffledPaths.toString()
                randomAngleList = randomAngles.toString()
                blockApply = false
            });
        }

        // Functions affecting preview image
        function createImageMosaic (targetImage) {
            var previewImagePath = tempImageFolderPath + "preview" + "-" + "collage" + ".tmp.png"

            const targetBackground = idComboBoxBackColor.currentIndex === 0
                                     ? "image"
                                     : idComboBoxBackColor.currentIndex === 1
                                       ? paintToolColor
                                       : idComboBoxBackColor.currentIndex === 2
                                        ? "#ff000000" // black
                                        : idComboBoxBackColor.currentIndex === 3
                                          ? "#ffffffff" // white
                                          : "#00000000" //transparent

            const targetFrameSetup = idComboBoxFrameColor.currentIndex === 0
                                     ? "none"
                                     : idComboBoxFrameColor.currentIndex === 1
                                       ? paintToolColor
                                       : idComboBoxFrameColor.currentIndex === 2
                                         ? "#ff000000"
                                         : "#ffffffff"

            if (idComboBoxAspect.currentIndex === 0) {
                ratioWanted = 3/2
            } else if (idComboBoxAspect.currentIndex === 1) {
                ratioWanted = 1
            } else if (idComboBoxAspect.currentIndex === 2) {
                ratioWanted = 2/3
            }

            if (targetImage === "preview") {
                var shuffle = "yes"
                var targetWidth = idPreviewImage.width
                var targetBlur = 20 // 1...50
                var targetSpacing = idSliderSpacing.value
              
                targetFrameSetup = targetFrameSetup + "," + idSliderFrameWidth.value
              
                if ( currentCollageType === "mosaic") {
                    call("graphx.createCollageMosaic", [ previewImagePath, inputPathPy, targetWidth , allSelectedPaths, 
                                                         shuffle, targetBackground, idSliderColumns.value, 
                                                         targetSpacing, targetBlur, targetImage, targetFrameSetup ])
                } else if ( currentCollageType === "lines") {
                    call("graphx.createCollageLines", [ previewImagePath, inputPathPy, targetWidth , allSelectedPaths, 
                                                        shuffle, targetBackground, idSliderHeight.value, targetSpacing, 
                                                        targetBlur, targetImage, targetFrameSetup ])
                } else if ( currentCollageType === "columns") {
                    call("graphx.createCollageColumns", [ previewImagePath, inputPathPy, targetWidth , allSelectedPaths,
                                                          shuffle, targetBackground, idSliderColumns.value, 
                                                          targetSpacing, targetBlur, targetImage, targetFrameSetup ])
                } else if ( currentCollageType === "polaroids") {
                    call("graphx.createCollagePolaroids", [ previewImagePath, inputPathPy, targetWidth , 
                                                            allSelectedPaths, shuffle, targetBackground, 
                                                            idSliderColumns.value, targetSpacing, targetBlur, 
                                                            targetImage, targetFrameSetup, randomAngleList, 
                                                            ratioWanted ])
                } else if ( currentCollageType === "scattered") {
                    call("graphx.createCollageScattered", [ previewImagePath, inputPathPy, targetWidth , 
                                                            allSelectedPaths, shuffle, targetBackground, 
                                                            idSliderColumns.value, targetSpacing, targetBlur, 
                                                            targetImage, targetFrameSetup, randomAngleList, 
                                                            ratioWanted ])
                }

                return
            }

            
            shuffle = "no"
            targetWidth = inputImageWidth
            targetBlur = Math.round(20 * ratioWidthOriginal2Preview)
            targetSpacing = Math.round(idSliderSpacing.value * ratioWidthOriginal2Preview)

            targetFrameSetup = targetFrameSetup + "," 
                               + Math.round(idSliderFrameWidth.value * ratioWidthOriginal2Preview)
            
            call("graphx.createCollageMiddleStepFunction", [ currentCollageType, targetWidth , allSelectedPaths, 
                                                             shuffle, targetBackground, idSliderColumns.value, 
                                                             targetSpacing, targetBlur, randomAngleList, ratioWanted, 
                                                             targetFrameSetup ])
            
            pageStack.pop()
        }


        onError: console.log('python error: ' + traceback);
        onReceived: console.log('got message from python: ' + data);
    } // end Python

    AppBar {
        id: appBar

        //% "Combine %1 images"
        readonly property string subheader: qsTrId("collage-bench-subheader").arg(selectedFilesCounter)

        //% "Collage"
        headerText: qsTrId("collage-bench-header")
        subHeaderText: warningLargeSize
                       //% "Output limited to %1px. %2" 
                       ? qsTrId("collage-bench-subheader-warning").arg(warningInputMaxWidth).arg(subheader)
                       : subheader 

        AppBarSpacer { }

        AppBarButton {
            icon.source: "image://theme/icon-splus-add"
            enabled: !page.blockApply

            onClicked: pageStack.push(multiImagePickerDialog)
        }

        AppBarButton {
            icon.source: "image://theme/icon-splus-sync"
            enabled: page.allSelectedPaths && !page.blockApply

            onClicked: {
                if (allSelectedPaths !== "") {
                    blockApply = true
                    py.createImageMosaic("preview")
                }
            }
        }

        AppBarButton {
            icon.source: "image://theme/icon-splus-accept"
            enabled: page.allSelectedPaths && !page.blockApply

            onClicked: py.createImageMosaic("original")
        }
    }

    SilicaFlickable {
        id: tutorial

        anchors {
            fill: parent
            topMargin: appBar.height
        }

        topMargin: Theme.paddingLarge
        bottomMargin: topMargin
        contentHeight: tutorialColumn.height
        opacity: !page.allSelectedPaths && !page.blockApply ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            FadeAnimation { }
        }

        Column {
            id: tutorialColumn

            width: parent.width

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: anchors.leftMargin
                }

                //% "Creating a collage"
                text: qsTrId("collage-bench-tutorial-title")
                font.pixelSize: Theme.fontSizeHuge
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }

            TutorialSection {
                //% "1. Start by adding images"
                title: qsTrId("collage-bench-tutorial-1-title")
                //% "Press the button above and select several images to start creating."
                summary: qsTrId("collage-bench-tutorial-1-summary")
            }

            TutorialSection {
                //% "2. Adjust the parameters"
                title: qsTrId("collage-bench-tutorial-2-title")
                //% "Use menus and sliders below to adjust your collage's parameters. Don't forget to tap the \"Refresh\" button after making changes."
                summary: qsTrId("collage-bench-tutorial-2-summary")
            }

            TutorialSection {
                //% "3. Save your work"
                title: qsTrId("collage-bench-tutorial-3-title")
                //% "When you are done, tap the check-mark button above to replace your image with the new collage."
                summary: qsTrId("collage-bench-tutorial-3-summary")
            }
        }
    }

    ExtendedBusyLabel {
        running: page.blockApply
    }

    SilicaFlickable {
        id: listView

        anchors {
            fill: parent
            topMargin: appBar.height
        }

        contentHeight: columnMoods.height
        topMargin: Theme.paddingLarge
        bottomMargin: topMargin
        opacity: page.allSelectedPaths && !page.blockApply ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            FadeAnimation { }
        }

        VerticalScrollDecorator { }

        Column {
            id: columnMoods

            width: page.width

            Image {
                id: idPreviewImage

                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingLarge + Theme.paddingSmall
                    rightMargin: Theme.paddingLarge + Theme.paddingSmall
                }
                
                fillMode: Image.PreserveAspectFit
                source: ""
                cache: false
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }

            ComboBox {
                id: idComboBoxPresets

                enabled: (blockApply === false)
                width: parent.width
                //% "layout generator:"
                label: qsTrId("collage-bench-combobox-preset-label") + " "
                
                menu: ContextMenu {
                    MenuItem {
                        //% "auto-rows"
                        text: qsTrId("collage-bench-preset-auto-rows")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "auto-columns"
                        text: qsTrId("collage-bench-preset-auto-columns")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "mosaic"
                        text: qsTrId("collage-bench-preset-mosaic")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "photowall"
                        text: qsTrId("collage-bench-preset-photowall")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "scattered"
                        text: qsTrId("collage-bench-preset-scattered")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
                
                onValueChanged: {
                    if (currentIndex === 0) {
                        currentCollageType = "lines"
                    }
                    else if (currentIndex === 1) {
                        currentCollageType = "columns"
                    }
                    else if (currentIndex === 2) {
                        currentCollageType = "mosaic"
                    }
                    else if (currentIndex === 3) {
                        currentCollageType = "polaroids"
                    }
                    else if (currentIndex === 4) {
                        currentCollageType = "scattered"
                    }
                }
            }

            ComboBox {
                id: idComboBoxBackColor
                
                enabled: (blockApply === false)
                width: parent.width
                //% "background:"
                label: qsTrId("collage-bench-combobox-background-label") + " "
                
                menu: ContextMenu {
                    MenuItem {
                        //% "blurry image"
                        text: qsTrId("collage-bench-background-blurry-image")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "current color"
                        text: qsTrId("collage-bench-background-current-color")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "black"
                        text: qsTrId("collage-bench-background-black")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "white"
                        text: qsTrId("collage-bench-background-white")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "transparent"
                        text: qsTrId("collage-bench-background-transparent")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }

            ComboBox {
                id: idComboBoxFrameColor
                
                enabled: (blockApply === false)
                width: parent.width
                //% "frames:"
                label: qsTrId("collage-bench-combobox-frames-label") + " "
                
                menu: ContextMenu {
                    MenuItem {
                        //% "none"
                        text: qsTrId("collage-bench-frame-none")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "current color"
                        text: qsTrId("collage-bench-frame-current-color")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "black"
                        text: qsTrId("collage-bench-frame-black")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "white"
                        text: qsTrId("collage-bench-frame-white")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }

            ComboBox {
                id: idComboBoxAspect
                
                visible: (currentCollageType === "polaroids")
                enabled: (blockApply === false)
                width: parent.width
                //% "ratio:"
                label: qsTrId("collage-bench-combobox-ratio-label") + " "
                
                menu: ContextMenu {
                    MenuItem {
                        //% "3 : 2"
                        text: qsTrId("collage-bench-aspect-3-2")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "1 : 1"
                        text: qsTrId("collage-bench-aspect-1-1")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                    MenuItem {
                        //% "2 : 3"
                        text: qsTrId("collage-bench-aspect-2-3")
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
            }

            Slider {
                id: idSliderHeight

                visible: (currentCollageType === "lines")
                enabled: (blockApply === false)
                width: parent.width
                height: Theme.itemSizeSmall * 1.1
                leftMargin: Theme.paddingLarge + Theme.paddingSmall
                rightMargin: Theme.paddingLarge + Theme.paddingSmall
                minimumValue: 1
                maximumValue: 7
                value: 3
                stepSize: 1
                smooth: true
                //% "Height: 1/%1 of width"
                label: qsTrId("collage-bench-slider-height").arg(idSliderHeight.value)
            }

            Slider {
                id: idSliderColumns
                
                visible: currentCollageType === "mosaic" 
                         || currentCollageType === "polaroids" 
                         || currentCollageType === "columns" 
                         || currentCollageType === "scattered"
                
                enabled: (blockApply === false)
                width: parent.width
                height: Theme.itemSizeSmall * 1.1
                leftMargin: Theme.paddingLarge + Theme.paddingSmall
                rightMargin: Theme.paddingLarge + Theme.paddingSmall
                minimumValue: 1
                maximumValue: 7
                value: 3
                stepSize: 1
                smooth: true
                //% "Columns: %1"
                label: qsTrId("collage-bench-slider-columns").arg(idSliderColumns.value)
            }

            Slider {
                id: idSliderSpacing
                
                enabled: (blockApply === false)
                width: parent.width
                height: Theme.itemSizeSmall * 1.1
                leftMargin: Theme.paddingLarge + Theme.paddingSmall
                rightMargin: Theme.paddingLarge + Theme.paddingSmall
                minimumValue: 0
                maximumValue: 5 * Theme.paddingSmall
                value: Theme.paddingSmall
                stepSize: Theme.paddingSmall / 2
                smooth: true
                //% "Spacing: %1"
                label: qsTrId("collage-bench-slider-spacing").arg(idSliderSpacing.value)
            }

            Slider {
                id: idSliderFrameWidth
                
                enabled: (blockApply === false)
                visible: (idComboBoxFrameColor.currentIndex !== 0)
                width: parent.width
                height: Theme.itemSizeSmall * 1.1
                leftMargin: Theme.paddingLarge + Theme.paddingSmall
                rightMargin: Theme.paddingLarge + Theme.paddingSmall
                minimumValue: 0
                maximumValue: 5 * Theme.paddingSmall
                value: Theme.paddingSmall
                stepSize: Theme.paddingSmall / 2
                smooth: true
                //% "Frame width: %1"
                label: qsTrId("collage-bench-slider-frame-width").arg(idSliderFrameWidth.value)
            }
        } // end Column
    } // end Silica Flickable
}
