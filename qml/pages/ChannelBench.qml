import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Aurora.Controls 1.0
import io.thp.pyotherside 1.5

Page {
    id: page

    //% "Keep original"
    readonly property string optionKeepOriginal: qsTrId("channel-bench-option-keep-original")
    //% "Replace with"
    readonly property string optionReplaceWith: qsTrId("channel-bench-option-replace-with")
    //% "Load"
    readonly property string optionLoadChannelFile: qsTrId("channel-bench-option-load-channel-file")
    
    //% "Gray"
    readonly property string colorNameGray: qsTrId("channel-bench-color-gray")
    //% "Alpha"
    readonly property string colorNameAlpha: qsTrId("channel-bench-color-alpha")
    //% "Red"
    readonly property string colorNameRed: qsTrId("channel-bench-color-red")
    //% "Green"
    readonly property string colorNameGreen: qsTrId("channel-bench-color-green")
    //% "Blue"
    readonly property string colorNameBlue: qsTrId("channel-bench-color-blue")

    //% "Normal"
    readonly property string channelTypeNormal: qsTrId("channel-bench-channel-type-normal")
    //% "Inverted"
    readonly property string channelTypeInverted: qsTrId("channel-bench-channel-type-inverted")

    // values transmitted from FirstPage.qml
    property var inputPathPy
    property var outputPathPy

    // variables for UI
    property var itemsPerRow : 5
    property var alphaDetailPicker : 0
    property var redDetailPicker : 0
    property var greenDetailPicker : 0
    property var blueDetailPicker : 0

    // variables for calculation
    property var channelPathAlpha : "original"
    property var channelPathRed : "original"
    property var channelPathGreen : "original"
    property var channelPathBlue : "original"
    property var fileNameAlpha : ""
    property var fileNameRed : ""
    property var fileNameGreen : ""
    property var fileNameBlue : ""
    property var factorA : "gray"
    property var factorR : "gray"
    property var factorG : "gray"
    property var factorB : "gray"
    property var invertA : "keep"
    property var invertR : "keep"
    property var invertG : "keep"
    property var invertB : "keep"

    allowedOrientations: Orientation.All

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../python'));
            importModule('graphx', function () {}); // Which Python file will be used?
        }

        // calculate functions in py
        function rechannelMiddleStepFunction() {
            var saturationA = alphaSliderIntensity.value
            var saturationR = redSliderIntensity.value
            var saturationG = greenSliderIntensity.value
            var saturationB = blueSliderIntensity.value

            call("graphx.rechannelMiddleStepFunction", [ channelPathAlpha, channelPathRed, channelPathGreen, 
                                                         channelPathBlue, factorA, factorR, factorG, factorB, 
                                                         saturationA, saturationR, saturationG, saturationB, invertA, 
                                                         invertR, invertG, invertB ])
        }

        onError: console.log('python error: ' + traceback)
        onReceived: console.log('got message from python: ' + data)
    } // end Python

    AppBar {
        id: appBar

        //% "Channel bench"
        headerText: qsTrId("channel-bench-title")
        //% "Replace, invert and saturate"
        subHeaderText: qsTrId("channel-bench-subtitle")
    }

    SilicaFlickable {
        id: listView

        anchors {
            fill: parent
            topMargin: appBar.height
        }

        contentHeight: columnSaveAs.height
        topMargin: Theme.paddingLarge
        bottomMargin: Theme.paddingLarge

        VerticalScrollDecorator { }

        Column {
            id: columnSaveAs

            width: page.width

            Row {
                id: idRecolorizeInfoRow
                
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                
                Row {
                    width: parent.width /  itemsPerRow * (itemsPerRow-1)
                
                    Label {
                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        //% "Alpha"
                        text: qsTrId("channel-bench-channel-alpha")
                    }
                
                    Label {
                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        //% "Red"
                        text: qsTrId("channel-bench-channel-red")
                    }
                
                    Label {
                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        //% "Green"
                        text: qsTrId("channel-bench-channel-green")
                    }
                
                    Label {
                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        //% "Blue"
                        text: qsTrId("channel-bench-channel-blue")
                    }
                }

                IconButton {
                    id: idApplyButton

                    visible:  true
                    width: parent.width / itemsPerRow
                    height: Theme.itemSizeSmall

                    icon {
                        source: "../symbols/icon-m-apply.svg"
                        width: Theme.iconSizeMedium
                        height: Theme.iconSizeMedium
                    }

                    onClicked: {
                        py.rechannelMiddleStepFunction()
                        pageStack.pop()
                    }
                }
            }

            Row {
                id: idReplaceOrKeepRow
                
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                
                Row {
                    width: parent.width /  itemsPerRow * (itemsPerRow-1)

                    IconButton {
                        id: idAlphaReplace
                
                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        icon.scale: 1
                
                        Label {
                            id: idAlphaReplaceLabel
                
                            width: parent.width
                            height: parent.height
                            color: Theme.highlightColor
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: page.optionKeepOriginal
                        }
                
                        onClicked: {
                            if (idAlphaPicker.enabled === false) {
                                idAlphaReplaceLabel.text = page.optionReplaceWith
                                idAlphaPicker.enabled = true
                            }
                            else {
                                idAlphaReplaceLabel.text =page.optionKeepOriginal
                                idAlphaPicker.enabled = false
                            }
                        }
                    }
                
                    IconButton {
                        id: idRedReplace
                
                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        icon.scale: 1
                
                        Label {
                            id: idRedReplaceLabel
                
                            width: parent.width
                            height: parent.height
                            color: Theme.highlightColor
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: page.optionKeepOriginal
                        }
                
                        onClicked: {
                            if (idRedPicker.enabled === false) {
                                idRedReplaceLabel.text = page.optionReplaceWith
                                idRedPicker.enabled = true
                            }
                            else {
                                idRedReplaceLabel.text =page.optionKeepOriginal
                                idRedPicker.enabled = false
                            }
                        }
                    }
                
                    IconButton {
                        id: idGreenReplace
                
                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        icon.scale: 1
                
                        Label {
                            id: idGreenReplaceLabel
                
                            width: parent.width
                            height: parent.height
                            color: Theme.highlightColor
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: page.optionKeepOriginal
                        }
                
                        onClicked: {
                            if (idGreenPicker.enabled === false) {
                                idGreenReplaceLabel.text = page.optionReplaceWith
                                idGreenPicker.enabled = true
                            }
                            else {
                                idGreenReplaceLabel.text =page.optionKeepOriginal
                                idGreenPicker.enabled = false
                            }
                        }
                    }
                
                    IconButton {
                        id: idBlueReplace
                
                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        icon.scale: 1
                
                        Label {
                            id: idBlueReplaceLabel
                
                            width: parent.width
                            height: parent.height
                            color: Theme.highlightColor
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: page.optionKeepOriginal
                        }
                
                        onClicked: {
                            if (idBluePicker.enabled === false) {
                                idBlueReplaceLabel.text = page.optionReplaceWith
                                idBluePicker.enabled = true
                            }
                            else {
                                idBlueReplaceLabel.text =page.optionKeepOriginal
                                idBluePicker.enabled = false
                            }
                        }
                    }
                }
            }

            Row {
                id: idLoadFileForChannel
                
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                
                IconButton {
                    id: idAlphaPicker
                
                    enabled: false
                    width: parent.width / 5
                    height: Theme.itemSizeSmall
                
                    onClicked: pageStack.push(alphaPickerPage)
                
                    Label {
                        visible: (idAlphaPicker.enabled) ? true : false
                        width: parent.width
                        height: parent.height
                        color: Theme.highlightColor
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        truncationMode: TruncationMode.Elide
                        text: (fileNameAlpha === "") ? page.optionLoadChannelFile : fileNameAlpha
                    }
                }

                IconButton {
                    id: idRedPicker
                
                    enabled: false
                    width: parent.width / 5
                    height: Theme.itemSizeSmall
                
                    onClicked: pageStack.push(redPickerPage)
                    
                    Label {
                        visible: (idRedPicker.enabled) ? true : false
                        width: parent.width
                        height: parent.height
                        color: Theme.highlightColor
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        truncationMode: TruncationMode.Elide
                        text: (fileNameRed === "") ? page.optionLoadChannelFile : fileNameRed
                    }
                }
             
                IconButton {
                    id: idGreenPicker
             
                    enabled: false
                    width: parent.width / 5
                    height: Theme.itemSizeSmall
             
                    onClicked: pageStack.push(greenPickerPage)
                    
                    Label {
                        visible: (idGreenPicker.enabled) ? true : false
                        width: parent.width
                        height: parent.height
                        color: Theme.highlightColor
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        truncationMode: TruncationMode.Elide
                        text: (fileNameGreen === "") ? page.optionLoadChannelFile : fileNameGreen
                    }
                }
                
                IconButton {
                    id: idBluePicker
                
                    enabled: false
                    width: parent.width / 5
                    height: Theme.itemSizeSmall
                
                    onClicked: pageStack.push(bluePickerPage)

                    Label {
                        visible: (idBluePicker.enabled) ? true : false
                        width: parent.width
                        height: parent.height
                        color: Theme.highlightColor
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        truncationMode: TruncationMode.Elide
                        text: (fileNameBlue === "") ? page.optionLoadChannelFile : fileNameBlue
                    }
                }
            }

            Row {
                id: idDetailChannelPicker
      
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge

                IconButton {
                    id: idAlphaDetail
      
                    enabled: (idAlphaPicker.enabled === true && channelPathAlpha !== "original") ? true : false
                    width: parent.width / 5
                    height: Theme.itemSizeSmall
      
                    Label {
                        id: idAlphaDetailLabel
      
                        width: parent.width
                        height: parent.height
                        color:  (parent.enabled) ? Theme.highlightColor : "transparent"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: page.colorNameGray
                    }
      
                    onClicked: {
                        alphaDetailPicker = alphaDetailPicker + 1
      
                        if (alphaDetailPicker === 0) {
                            idAlphaDetailLabel.text = page.colorNameGray
                            factorA = "gray"
                        }
      
                        if (alphaDetailPicker === 1) {
                            idAlphaDetailLabel.text = page.colorNameAlpha
                            factorA = "A"
                        }
      
                        if (alphaDetailPicker === 2) {
                            idAlphaDetailLabel.text = page.colorNameRed
                            factorA = "R"
                        }
      
                        if (alphaDetailPicker === 3) {
                            idAlphaDetailLabel.text = page.colorNameGreen
                            factorA = "G"
                        }
      
                        if (alphaDetailPicker === 4) {
                            idAlphaDetailLabel.text = page.colorNameBlue
                            factorA = "B"
                            alphaDetailPicker = -1
                        }
                    }
                }
      
                IconButton {
                    id: idRedDetail
      
                    enabled: (idRedPicker.enabled === true && channelPathRed !== "original") ? true : false
                    width: parent.width / 5
                    height: Theme.itemSizeSmall
      
                    Label {
                        id: idRedDetailLabel
      
                        width: parent.width
                        height: parent.height
                        color:  (parent.enabled) ? Theme.highlightColor : "transparent"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: page.colorNameGray
                    }
      
                    onClicked: {
                        redDetailPicker = redDetailPicker + 1
      
                        if (redDetailPicker === 0) {
                            idRedDetailLabel.text = page.colorNameGray
                            factorR = "gray"
                        }
      
                        if (redDetailPicker === 1) {
                            idRedDetailLabel.text = page.colorNameAlpha
                            factorR = "A"
                        }
                        if (redDetailPicker === 2) {
                            idRedDetailLabel.text = page.colorNameRed
                            factorR = "R"
                        }
      
                        if (redDetailPicker === 3) {
                            idRedDetailLabel.text = page.colorNameGreen
                            factorR = "G"
                        }
      
                        if (redDetailPicker === 4) {
                            idRedDetailLabel.text = page.colorNameBlue
                            factorR = "B"
                            redDetailPicker = -1
                        }
                    }
                }
      
                IconButton {
                    id: idGreenDetail
      
                    enabled: (idGreenPicker.enabled === true && channelPathGreen !== "original") ? true : false
                    width: parent.width / 5
                    height: Theme.itemSizeSmall
      
                    Label {
                        id: idGreenDetailLabel
      
                        width: parent.width
                        height: parent.height
                        color:  (parent.enabled) ? Theme.highlightColor : "transparent"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: page.colorNameGray
                    }
      
                    onClicked: {
                        greenDetailPicker = greenDetailPicker + 1
      
                        if (redDetailPicker === 0) {
                            idGreenDetailLabel.text = page.colorNameGray
                            factorG = "gray"
                        }
      
                        if (greenDetailPicker === 1) {
                            idGreenDetailLabel.text = page.colorNameAlpha
                            factorG = "A"
                        }
      
                        if (greenDetailPicker === 2) {
                            idGreenDetailLabel.text = page.colorNameRed
                            factorG = "R"
                        }
      
                        if (greenDetailPicker === 3) {
                            idGreenDetailLabel.text = page.colorNameGreen
                            factorG = "G"
                        }
      
                        if (greenDetailPicker === 4) {
                            idGreenDetailLabel.text = page.colorNameBlue
                            factorG = "B"
                            greenDetailPicker = -1
                        }
                    }
                }
      
                IconButton {
                    id: idBlueDetail
      
                    enabled: (idBluePicker.enabled === true && channelPathBlue !== "original") ? true : false
                    width: parent.width / 5
                    height: Theme.itemSizeSmall
      
                    Label {
                        id: idBlueDetailLabel
      
                        width: parent.width
                        height: parent.height
                        color:  (parent.enabled) ? Theme.highlightColor : "transparent"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Theme.paddingLarge
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: page.colorNameGray
                    }
      
                    onClicked: {
                        blueDetailPicker = blueDetailPicker + 1
      
                        if (blueDetailPicker === 0) {
                            idBlueDetailLabel.text = page.colorNameGray
                            factorB = "gray"
                        }
      
                        if (blueDetailPicker === 1) {
                            idBlueDetailLabel.text = page.colorNameAlpha
                            factorB = "A"
                        }
      
                        if (blueDetailPicker === 2) {
                            idBlueDetailLabel.text = page.colorNameRed
                            factorB = "R"
                        }
      
                        if (blueDetailPicker === 3) {
                            idBlueDetailLabel.text = page.colorNameGreen
                            factorB = "G"
                        }
      
                        if (blueDetailPicker === 4) {
                            idBlueDetailLabel.text = page.colorNameBlue
                            factorB = "B"
                            blueDetailPicker = -1
                        }
                    }
                }

                Label {
                    visible: idAlphaDetail.enabled 
                             || idRedDetail.enabled 
                             || idGreenDetail.enabled 
                             || idBlueDetail.enabled

                    width: parent.width / 5
                    height: Theme.itemSizeSmall
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeExtraSmall

                    // Displayed right of the channel mixer, 
                    // indicates that we will "use" the *color* channel from the selected file
                    //% "using"
                    text: qsTrId("channel-bench-selector-subtitle")
                }
            }

            Row {
                id: idInvertChannel

                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge

                Row {
                    width: parent.width /  itemsPerRow * (itemsPerRow-1)

                    IconButton {
                        id: idAlphaInvert

                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        icon.scale: 1

                        Label {
                            id: idAlphaInvertLabel

                            width: parent.width
                            height: parent.height
                            color: Theme.highlightColor
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: page.channelTypeNormal
                        }

                        onClicked: {
                            if (invertA === "keep") {
                                idAlphaInvertLabel.text = page.channelTypeInverted
                                invertA = "invert"
                            }
                            else {
                                idAlphaInvertLabel.text =page.channelTypeNormal
                                invertA = "keep"
                            }
                        }
                    }

                    IconButton {
                        id: idRedInvert

                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        icon.scale: 1

                        Label {
                            id: idRedInvertLabel

                            width: parent.width
                            height: parent.height
                            color: Theme.highlightColor
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: page.channelTypeNormal
                        }

                        onClicked: {
                            if (invertR === "keep") {
                                idRedInvertLabel.text = page.channelTypeInverted
                                invertR = "invert"
                            }
                            else {
                                idRedInvertLabel.text =page.channelTypeNormal
                                invertR = "keep"
                            }
                        }
                    }

                    IconButton {
                        id: idGreenInvert

                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        icon.scale: 1

                        Label {
                            id: idGreenInvertLabel

                            width: parent.width
                            height: parent.height
                            color: Theme.highlightColor
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: page.channelTypeNormal
                        }

                        onClicked: {
                            if (invertG === "keep") {
                                idGreenInvertLabel.text = page.channelTypeInverted
                                invertG = "invert"
                            }
                            else {
                                idGreenInvertLabel.text =page.channelTypeNormal
                                invertG = "keep"
                            }
                        }
                    }

                    IconButton {
                        id: idBlueInvert

                        width: parent.width / 4
                        height: Theme.itemSizeSmall
                        icon.scale: 1

                        Label {
                            id: idBlueInvertLabel

                            width: parent.width
                            height: parent.height
                            color: Theme.highlightColor
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeExtraSmall
                            text: page.channelTypeNormal
                        }

                        onClicked: {
                            if (invertB === "keep") {
                                idBlueInvertLabel.text = page.channelTypeInverted
                                invertB = "invert"
                            }
                            else {
                                idBlueInvertLabel.text =page.channelTypeNormal
                                invertB = "keep"
                            }
                        }
                    }

                }
            }

            Rectangle {
                width: parent.width
                height: Theme.paddingLarge * 1.5
                color: "transparent"
            }

            Row {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                height: Theme.itemSizeMedium

                Row {
                    width: parent.width /  itemsPerRow * (itemsPerRow-1)

                    Slider {
                        id: alphaSliderIntensity

                        width: parent.width
                        height: Theme.itemSizeSmall
                        minimumValue: 0
                        maximumValue: 2
                        value: 1
                        stepSize: 0.01
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                        smooth: true

                        Label {
                            anchors {
                                bottom: parent.bottom
                                bottomMargin: -Theme.paddingMedium
                                horizontalCenter: parent.horizontalCenter
                            }

                            text: page.colorNameAlpha + " " + alphaSliderIntensity.value
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            }

            Row {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                height: Theme.itemSizeMedium

                Row {
                    width: parent.width /  itemsPerRow * (itemsPerRow-1)

                    Slider {
                        id: redSliderIntensity

                        width: parent.width
                        height: Theme.itemSizeSmall
                        minimumValue: 0
                        maximumValue: 2
                        value: 1
                        stepSize: 0.01
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                        smooth: true

                        Label {
                            anchors {
                                bottom: parent.bottom
                                bottomMargin: -Theme.paddingMedium
                                horizontalCenter: parent.horizontalCenter
                            }

                            text: page.colorNameRed + " " + redSliderIntensity.value
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            }

            Row {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                height: Theme.itemSizeMedium

                Row {
                    width: parent.width /  itemsPerRow * (itemsPerRow-1)

                    Slider {
                        id: greenSliderIntensity

                        width: parent.width
                        height: Theme.itemSizeSmall
                        minimumValue: 0
                        maximumValue: 2
                        value: 1
                        stepSize: 0.01
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                        smooth: true

                        Label {
                            anchors {
                                bottom: parent.bottom
                                bottomMargin: -Theme.paddingMedium
                                horizontalCenter: parent.horizontalCenter
                            }

                            text: page.colorNameGreen + " " + greenSliderIntensity.value
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            }

            Row {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge
                height: Theme.itemSizeMedium

                Row {
                    width: parent.width /  itemsPerRow * (itemsPerRow-1)

                    Slider {
                        id: blueSliderIntensity

                        width: parent.width
                        height: Theme.itemSizeSmall
                        minimumValue: 0
                        maximumValue: 2
                        value: 1
                        stepSize: 0.01
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                        smooth: true

                        Label {
                            anchors {
                                bottom: parent.bottom
                                bottomMargin: -Theme.paddingMedium
                                horizontalCenter: parent.horizontalCenter
                            }

                            text: page.colorNameBlue + " " + blueSliderIntensity.value
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            }
        } // end Column
    } // end Silica Flickable

    Component {
       id: alphaPickerPage

       FilePickerPage {
            //% "Select alpha channel provider"
           title: qsTrId("channel-bench-file-picker-alpha")
           nameFilters: [ '*.jpg', '*.jpeg', '*.png', '*.tif', '*.tiff', '*.bmp', '*.gif' ]

           onSelectedContentPropertiesChanged: {
               channelPathAlpha = selectedContentProperties.filePath
               fileNameAlpha = selectedContentProperties.fileName
           }
       }
    }

    Component {
       id: redPickerPage

       FilePickerPage {
            //% "Select red channel provider"
           title: qsTrId("channel-bench-file-picker-red")
           nameFilters: [ '*.jpg', '*.jpeg', '*.png', '*.tif', '*.tiff', '*.bmp', '*.gif' ]

           onSelectedContentPropertiesChanged: {
               channelPathRed = selectedContentProperties.filePath
               fileNameRed = selectedContentProperties.fileName
           }
       }
    }
    
    Component {
       id: greenPickerPage

       FilePickerPage {
            //% "select green channel provider"
           title: qsTrId("channel-bench-file-picker-green")
           nameFilters: [ '*.jpg', '*.jpeg', '*.png', '*.tif', '*.tiff', '*.bmp', '*.gif' ]

           onSelectedContentPropertiesChanged: {
               channelPathGreen = selectedContentProperties.filePath
               fileNameGreen = selectedContentProperties.fileName
           }
       }
    }

    Component {
       id: bluePickerPage

       FilePickerPage {
            //% "Select blue channel provider"
           title: qsTrId("channel-bench-file-picker-blue")
           nameFilters: [ '*.jpg', '*.jpeg', '*.png', '*.tif', '*.tiff', '*.bmp', '*.gif' ]

           onSelectedContentPropertiesChanged: {
               channelPathBlue = selectedContentProperties.filePath
               fileNameBlue = selectedContentProperties.fileName
           }
       }
    }
}
