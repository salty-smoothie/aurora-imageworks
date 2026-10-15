import QtQuick 2.6
import Sailfish.Silica 1.0

Item {
    property bool running

    anchors.fill: parent
    opacity: running ? 1 : 0
    visible: opacity > 0

    onRunningChanged: {
        if (running) {
            timer.restart()
        } else {
            timer.stop()
            descriptionLabel.opacity = 0
        }
    }

    Behavior on opacity {
        FadeAnimation { }
    }

    Column {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }

        spacing: Theme.paddingLarge

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
            opacity: 1
        }

        InfoLabel {
            //% "Applying changes"
            text: qsTrId("extended-busy-label-title")
        }
    }

    Label {
        id: descriptionLabel

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
            bottomMargin: Theme.paddingLarge
        }

        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        color: Theme.secondaryColor
        //% "Some changes take longer to process.\nDo not close Imageworks while this operation is in progress."
        text: qsTrId("extended-busy-label-subtitle")
        font.pixelSize: Theme.fontSizeSmall
        opacity: 0

        Behavior on opacity {
            FadeAnimation { }
        }
    }

    Timer {
        id: timer

        interval: 3 * 1000

        onTriggered: descriptionLabel.opacity = 1
    }
}
