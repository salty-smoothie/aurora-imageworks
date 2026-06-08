import QtQuick 2.6
import Sailfish.Silica 1.0
import Aurora.Controls 1.0
import io.thp.pyotherside 1.5

import "../components"

Page {
    id: page

    readonly property bool canSave: !processing && fileExtensionCombo.multiPagePdfCreation === pageNumberMultiPDF > 0

    // values transmitted from FirstPage.qml
    property var homeDirectory
    property var origImageFileName
    property var origImageFolderPath
    property var tempImageFolderPath
    property var imageWidthSave
    property var imageHeightSave
    property var inputPathPy

    // variables for saving
    property var oldFileType
    property var oldFileName
    property var origImageFileNameArray
    property var savePath
    property var estimatedFileSize
    property var pageNumberMultiPDF : 0
    property var multiPdfPageNamesList : ""
    property bool validatorNameOverwrite : false

    // variables for warning overwrite
    property var estimatedFolder

    property bool processing

    allowedOrientations: Orientation.All

    Component.onCompleted: {
        // get infos from the original file
        origImageFileNameArray = origImageFileName.split(".")
        oldFileName = origImageFileNameArray.slice(0, origImageFileNameArray.length - 1).join(".")
        oldFileType = origImageFileNameArray[origImageFileNameArray.length - 1]

        if (oldFileType.indexOf('jpg') !== -1 || oldFileType.indexOf('jpeg') !== -1) {
            fileExtensionCombo.currentIndex = 0
        } else if (oldFileType.indexOf('png') !== -1) {
            fileExtensionCombo.currentIndex = 1
        } else if (oldFileType.indexOf('gif') !== -1) {
            fileExtensionCombo.currentIndex = 2
        } else if (oldFileType.indexOf('bmp') !== -1) {
            fileExtensionCombo.currentIndex = 3
        } else {
            // suggested file format if none of the above
            fileExtensionCombo.currentIndex = 0
        }

        py.getImageSizeFunction()
        py.getMultiPdfPagesFunction()
    }

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../python'))
            importModule('graphx', function () { })

            setHandler('tempFilesDeleted', function(i) { console.log("temp files deleted:", i) })

            setHandler('estimatedFileSize', function(estimatedSize) {
                estimatedFileSize = Math.round(parseInt(estimatedSize) / 10) / 100
            })

            setHandler('fileIsSaved', function() { pageStack.pop() })
            setHandler('fileMultiPagePdfIsAdded', function() { page.processing = false })

            setHandler('getPagesMultiPDF', function(pagesCounter, pagesNamesList) {
                pageNumberMultiPDF = parseInt(pagesCounter)
                multiPdfPageNamesList = pagesNamesList
            })

            setHandler('tempMultiPDFfilesDeleted', function() { page.processing = false })
            setHandler('debugPythonLogs', function(i) { console.log(i) })
        }

        // file operations
        
        function saveFunction() {
            page.processing = true

            var folderSavePath = targetFolderCombo.path

            savePath = folderSavePath + idFilenameNew.text.toString() + fileExtensionCombo.value
            inputPathPy = ( "/" + inputPathPy.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"") )
            var fileTargetType = fileExtensionCombo.value
            var pdfResolution = 300

            const args = [ inputPathPy, savePath, tempImageFolderPath, pdfResolution, fileTargetType ]
            call("graphx.saveNowFunction", args)
        }

        function getImageSizeFunction() {
            inputPathPy = decodeURIComponent("/" + inputPathPy.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,""))
            call("graphx.getImageSizeFunction", [ inputPathPy ])
        }

        function gatherMultiPagePdfFunction() {
            page.processing = true
            pageNumberMultiPDF = pageNumberMultiPDF + 1

            multiPdfPageNamesList = multiPdfPageNamesList + pageNumberMultiPDF 
                                    + "-" + idFilenameNew.text.toString() + "\n"

            inputPathPy = inputPathPy.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")

            call("graphx.gatherMultiPagePdfFunction", [ inputPathPy, pageNumberMultiPDF, multiPdfPageNamesList ])
        }

        function getMultiPdfPagesFunction() {
            call("graphx.getMultiPdfPagesFunction", [])
        }

        function deleteTempMultiPagePDF() {
            call("graphx.deleteTempMultiPagePDF", [ tempImageFolderPath ])
        }

        function createMultiPagePDFFunction() {
            const folderSavePath = targetFolderCombo.path
            savePath = folderSavePath + multiPagePdfFilename.text + ".pdf"
            call("graphx.createMultiPagePDFFunction", [ savePath, tempImageFolderPath ])
        }

        onError: console.log('python error: ' + traceback);
        onReceived: console.log('got message from python: ' + data);
    } // end Python

    AppBar {
        id: appBar

        //% "Save as..."
        headerText: qsTrId("save-page-header")

        AppBarSpacer { }

        AppBarButton {
            icon.source: "image://theme/icon-splus-accept"
            enabled: page.canSave

            onClicked: {
                if (fileExtensionCombo.multiPagePdfCreation) {
                    py.createMultiPagePDFFunction()
                } else {
                    py.saveFunction()
                }
            }
        }
    }

    ExtendedBusyLabel {
        running: page.processing
    }

    SilicaFlickable {
        id: listView
        
        anchors {
            fill: parent
            topMargin: appBar.height
        }

        contentHeight: columnSaveAs.height
        opacity: page.processing ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            FadeAnimation { }
        }
        
        VerticalScrollDecorator { }

        Column {
            id: columnSaveAs

            width: page.width

            Row {
                width: parent.width

                TextField {
                    id: idFilenameNew

                    //% "Override..."
                    label: page.validatorNameOverwrite ? qsTrId("save-page-filename-override") : ""
                    enabled: !fileExtensionCombo.multiPagePdfCreation
                    width: parent.width - fileExtensionCombo.width
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingMedium
                    y: Theme.paddingSmall
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: oldFileName + "_edit"

                    validator: RegExpValidator { 
                        // negative list
                        regExp: /^[^<>'\"/;*:`#?]*$/ 
                    }
                    
                    EnterKey.onClicked: idFilenameNew.focus = false

                    onTextChanged: checkOverwriting()
                }

                ComboBox {
                    id: fileExtensionCombo

                    readonly property bool multiPagePdfCreation: currentIndex === 5
                    readonly property bool isDocument: currentIndex === 4 || currentIndex === 5
                    readonly property bool supportsTransparency: currentIndex === 1 || multiPagePdfCreation

                    width: {
                        var maxWidth = 0

                        for (var i = 0; i < menu.children.length; i++) {
                            maxWidth = Math.max(maxWidth, extensionMetrics.boundingRect(menu.children[i].text).width)
                        }

                        return maxWidth + Theme.paddingLarge * 4
                    }
                    
                    menu: ContextMenu {
                        MenuItem {
                            text: ".jpg"
                        }
                        MenuItem {
                            text: ".png"
                        }
                        MenuItem {
                            text: ".gif"
                        }
                        MenuItem {
                            text: ".bmp"
                        }
                        MenuItem {
                            text: ".pdf"
                        }
                        MenuItem {
                            text: "PDF+"
                        }
                    }

                    FontMetrics {
                        id: extensionMetrics
                    }
                }
            } // end row save filename

            Row {
                visible: fileExtensionCombo.multiPagePdfCreation
                width: parent.width
                
                TextField {
                    id: multiPagePdfFilename
                    
                    enabled: pageNumberMultiPDF > 0
                    width: parent.width - multiPdfExtensionCombo.width
                    anchors.top: parent.top
                    anchors.topMargin: Theme.paddingMedium
                    y: Theme.paddingSmall
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: "multipage"
                    
                    validator: RegExpValidator { 
                        regExp: /[a-zA-Z0-9äöüÄÖÜ_=()\/.!?#+-]*$/ 
                    }
                    
                    EnterKey.onClicked: idFilenameNew.focus = false
                }

                ComboBox {
                    id: multiPdfExtensionCombo
                    
                    enabled: false
                    width: fileExtensionCombo.width

                    menu: ContextMenu {
                        MenuItem {
                            text: ".pdf"
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            } // end row save filename

            ComboBox {
                id: targetFolderCombo
                
                readonly property string path: currentItem.path

                width: parent.width
                //% "Save location"
                label: qsTrId("save-page-combobox-save-location")
                
                menu: ContextMenu {
                    MenuItem {
                        readonly property string path: fileExtensionCombo.isDocument 
                                                       ? page.homeDirectory + "/Documents/"
                                                       : page.origImageFolderPath

                        //% "Original Folder"
                        text: fileExtensionCombo.isDocument ? "Documents" : qsTrId("save-page-location-original-folder")
                    }

                    MenuItem {
                        readonly property string path: page.homeDirectory + "/Pictures/Imageworks/"

                        text: "Pictures/Imageworks"
                    }

                    MenuItem {
                        readonly property string path: page.homeDirectory + "/Pictures/"

                        text: "Pictures"
                    }

                    MenuItem {
                        readonly property string path: page.homeDirectory + "/Downloads/"

                        text: "Downloads"
                    }

                    MenuItem {
                        readonly property string path: page.homeDirectory

                        text: "/home"
                    }
                }

                onCurrentItemChanged: checkOverwriting()
            }

            SectionHeader {
                visible: fileExtensionCombo.multiPagePdfCreation
                //% "Pages contained"
                text: qsTrId("save-page-section-pages-contained")
                horizontalAlignment: Text.AlignLeft
            }

            Item {
                width: 1
                height: Theme.paddingMedium
            }

            ButtonLayout {
                visible: fileExtensionCombo.multiPagePdfCreation

                Button {
                    icon.source: "image://theme/icon-splus-add"
                    //% "Add page"
                    text: qsTrId("save-page-button-add-page")

                    onClicked: py.gatherMultiPagePdfFunction()
                }

                Button {
                    icon.source: "image://theme/icon-splus-clear"
                    //% "Clear"
                    text: qsTrId("save-page-button-clear-pages")
                    enabled: page.pageNumberMultiPDF > 0

                    onClicked: py.deleteTempMultiPagePDF()
                }
            }


            Item {
                width: 1
                height: Theme.paddingMedium
                visible: fileExtensionCombo.multiPagePdfCreation
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: anchors.leftMargin
                }

                visible: fileExtensionCombo.multiPagePdfCreation
                font.pixelSize: Theme.fontSizeExtraSmall
                text: multiPdfPageNamesList
                wrapMode: Text.WordWrap
            }
            
            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: anchors.leftMargin
                }

                visible: !fileExtensionCombo.multiPagePdfCreation
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                
                //% "Original folder: %1\nWidth: %2\nHeight: %3\nSize: %4kb"
                text: qsTrId("save-page-file-properties")
                      .arg(origImageFolderPath)
                      .arg(imageWidthSave)
                      .arg(imageHeightSave)
                      .arg(estimatedFileSize)
            }

            Label {
                id: idWarningTransparencySupport
                
                visible: !fileExtensionCombo.supportsTransparency
                topPadding: Theme.iconSizeExtraSmall
                leftPadding: Theme.paddingLarge * 1.2
                width: parent.width - 2 * Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraSmall
                //% "Filetype does not support transparency."
                text: qsTrId("save-page-file-type-does-not-support-transparency")
            }
        } // end Column
    } // end Silica Flickable

    function checkOverwriting() {
        page.estimatedFolder = targetFolderCombo.path

        page.validatorNameOverwrite = page.estimatedFolder === origImageFolderPath 
                                      && oldFileName === idFilenameNew.text 
                                      && "." + oldFileType === fileExtensionCombo.value
    }
}
