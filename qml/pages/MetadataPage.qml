import QtQuick 2.6
import Sailfish.Silica 1.0
import Aurora.Controls 1.0
import io.thp.pyotherside 1.5


Page {
    id: page

    // values transmitted from FirstPage.qml
    property var origImageFileName
    property var origImageFolderPath
    property var inputPathPy

    // meta variables
    property var estimatedFileSize
    property var origImageFileNameArray
    property var fileName
    property var fileType
    property var imgDataFormat
    property var imgDataMode
    property var imgDataPalette
    property var imgDateWidth
    property var imgDataHeight
    property var imgDataExifFull
    property var metaPath

    allowedOrientations: Orientation.All

    Component.onCompleted: {
        // get infos from the original file
        py.getImageSizeFunction()
        py.getImageMetaDataFunction()
    }

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../py'))
            importModule('graphx', function () {})

            // Handlers = Signals to do something in QML whith received Infos from pyotherside.send
            setHandler('metaDataReceived', function(imgFormat, imgMode, imgPalette, imgWidth, imgHeight, imgExifFull) {
                imgDataFormat = imgFormat
                imgDataMode = imgMode
                imgDataPalette = imgPalette
                imgDateWidth = imgWidth
                imgDataHeight = imgHeight

                if (imgExifFull === "This file contains no EXIF tags.") {
                    //% "File contains no EXIF tags."
                    imgDataExifFull = qsTrId("metadata-page-no-exif-tags")
                } else if (imgExifFull === "Filetype does not support EXIF tags.") {
                    //% "Filetype does not support EXIF tags."
                    imgDataExifFull = qsTrId("metadata-page-no-exif-support")
                } else {
                    imgDataExifFull = imgExifFull
                }
            })

            setHandler('estimatedFileSize', function(estimatedSize) {
                estimatedFileSize = Math.round ( (parseInt(estimatedSize)/1000) * 100) / 100
            })
        }

        // meta data operations
        
        function getImageSizeFunction() {
            metaPath = origImageFolderPath + origImageFileName
            call("graphx.getImageSizeFunction", [ metaPath ])
        }
        
        function getImageMetaDataFunction() {
            metaPath = origImageFolderPath + origImageFileName
            inputPathPy = "/" + inputPathPy.replace(/^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/,"")
            call("graphx.getImageMetaDataFunction", [ metaPath ])
        }

        onError: console.log('python error: ' + traceback)
        onReceived: console.log('got message from python: ' + data)
    } // end Python

    AppBar {
        id: appBar

        //% "Metadata"
        headerText: qsTrId("metadata-page-header")
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

            width: parent.width

            SectionHeader {
                //% "File information"
                text: qsTrId("metadata-page-section-file-information")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                //% "File: %1\nPath: %2\nSize: %3kb\nWidth: %4px\nHeight: %5px\nFormat: %6\nMode: %7\nPalette: %8"
                text: qsTrId("metadata-page-file-information")
                      .arg(origImageFileName)
                      .arg(origImageFolderPath)
                      .arg(estimatedFileSize)
                      .arg(imgDateWidth)
                      .arg(imgDataHeight)
                      .arg(imgDataMode)
                      .arg(imgDataPalette)
            }

            SectionHeader {
                //% "EXIF tags"
                text: qsTrId("metadata-page-section-exif-tags")
                horizontalAlignment: Text.AlignLeft
            }

            Label {
                x: Theme.paddingLarge
                width: parent.width - 2 * Theme.paddingLarge
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                text: imgDataExifFull + "\n" + "\n"
            }

        } // end Column
    } // end Silica Flickable
}
