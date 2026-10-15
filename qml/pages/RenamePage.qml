import QtQuick 2.6
import Sailfish.Silica 1.0
import Aurora.Controls 1.0
import io.thp.pyotherside 1.5

Page {
    id: page

    // values transmitted from FirstPage.qml
    property var origImageFileName
    property var origImageFolderPath
    property var tempImageFolderPath
    property var origImageFilePath
    property var imageWidthSave
    property var imageHeightSave
    property var inputPathPy

    // variables for saving
    property var oldFileType
    property var oldFileName
    property var origImageFileNameArray
    property var savePath
    property var estimatedFileSize

    allowedOrientations: Orientation.All

    Component.onCompleted: {
        // get infos from the original file
        origImageFileNameArray = origImageFileName.split(".")
        oldFileName = (origImageFileNameArray.slice(0, origImageFileNameArray.length-1)).join(".")
        oldFileType = origImageFileNameArray[origImageFileNameArray.length - 1]
        idComboBoxFileExtension.currentIndex = 0
        py.getImageSizeFunction()
    }

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'))
            importModule('graphx', function () {})

            // Handlers = Signals to do something in QML whith received Infos from pyotherside.send
            setHandler('tempFilesDeleted', function(i) {
                console.log("temp files deleted: " + i)
            })

            setHandler('estimatedFileSize', function(estimatedSize) {
                estimatedFileSize = Math.round ( (parseInt(estimatedSize)/1000) * 100) / 100
            })
        }

        // file operations
        
        function getImageSizeFunction() {
            inputPathPy = decodeURIComponent( "/" + inputPathPy.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"") )
            call("graphx.getImageSizeFunction", [ inputPathPy ])
        }

        function renameOriginalFunction() {
            if (origImageFileName !== undefined) {
                inputPathPy = origImageFilePath
                var renamedImageFilePath = origImageFolderPath + idFilenameNew.text + "." + oldFileType
                call("graphx.renameOriginalFunction", [ inputPathPy, renamedImageFilePath ])
            } else {
                console.log("image not loaded")
            }
        }

        onError: console.log('python error: ' + traceback);
        onReceived: console.log('got message from python: ' + data);
    } // end Python

    AppBar {
        id: appBar

        //% "Rename as..."
        headerText: qsTrId("rename-page-header")

        AppBarSpacer { }

        AppBarButton {
            icon.source: "image://theme/icon-splus-accept"

            onClicked: {
                py.renameOriginalFunction()
                pageStack.pop()
            }
        }
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

                TextField {
                    id: idFilenameNew
                    
                    anchors {
                        top: parent.top
                        topMargin: Theme.paddingMedium
                    }

                    width: parent.width - idComboBoxFileExtension.width
                    inputMethodHints: Qt.ImhNoPredictiveText
                    text: origImageFileName !== undefined ? oldFileName : "none"
                    
                    validator: RegExpValidator { 
                        // negative list
                        regExp: /^[^<>'\"/;*:`#?]*$/ 
                    }
                    
                    EnterKey.onClicked: idFilenameNew.focus = false
                }

                ComboBox {
                    id: idComboBoxFileExtension

                    readonly property string extension: origImageFileName !== undefined ? ("." + oldFileType) : "???"

                    width: extensionMetrics.width + Theme.paddingLarge * 3

                    menu: ContextMenu {
                        MenuItem {
                            text: idComboBoxFileExtension.extension
                        }
                    }

                    TextMetrics {
                        id: extensionMetrics

                        text: idComboBoxFileExtension.extension
                    }
                }
            } // end row save filename

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }

                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall

                //% "Path: %1\nWidth: %2\nHeight: %3\nSize: %4kb"
                text: qsTrId("rename-page-file-properties")
                      .arg(origImageFolderPath)
                      .arg(imageWidthSave)
                      .arg(imageHeightSave)
                      .arg(estimatedSize)
            }
        } // end Column
    } // end Silica Flickable
}
