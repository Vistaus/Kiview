//SPDX-License-Identifier: GPL-3.0-or-later
//SPDX-FileCopyrightText: 2023 danilo agostini <nyre334@gmail.com>
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia
import CManager 1.0
import org.kde.kirigami as Kirigami



// Videos currently fail to play in Qt6/Qml via "QtMultimedia" on some Linux distributions.
// The reason seems to be that you need gstreamer 1.22 with qml6glsink and they are currently not available on kde neon (ubuntu 22.04).
Item{
    anchors.fill: parent
    property list<Kirigami.Action> actions
    //these actions are read by viewersLoader and are shown in the "header bar" of the application.
    actions: [OpenAppButton{}]

    Text{
        id:errorMessage
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: (videoFrame.errorString === "" ? false : true)
        text: videoFrame.errorString
        color: Kirigami.Theme.textColor
        font.pointSize: 20
    }

    Video {
        id: videoFrame
        focus: true

        //deprecated
        // autoPlay: true
        //at the end of the video it shows the last frame instead of becoming transparent.
        // flushMode: VideoOutput.LastFrame

        source: Manager.videoViewer.viewerMedia
        onSourceChanged: play()

        anchors{
            right: parent.right
            left: parent.left
            top: parent.top
            bottom: lineSeparator.top
        }

        onPositionChanged: {
            if (! videoSlider.pressed) videoSlider.value = videoFrame.position
        }

        onPlaybackStateChanged:{
            if (videoFrame.playbackState === MediaPlayer.StoppedState && videoFrame.position === videoFrame.duration)
                videoFrame.play()}

        MouseArea {
            anchors.fill: parent
            onClicked: {
                togglePlay()
            }
        }
    }


    Kirigami.Separator{
        id: lineSeparator
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: controlBar.top
    }

    Item{
        id:controlBar
        visible: (videoFrame.errorString === "" ? true : false)
        anchors{
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        height:30
        Button{
            id:togglePlayButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            flat:true
            onPressed: togglePlay()
            icon.name: (videoFrame.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start" )
        }


        Slider{
            id: videoSlider
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: togglePlayButton.right
            anchors.right: infoSection.left
            anchors.rightMargin: 20

            from: 0
            to: videoFrame.duration

            onPressedChanged: if ( ! videoSlider.pressed) videoFrame.seek(videoSlider.value)
        }

        Row{
            // bottomPadding: 4
            anchors.verticalCenter: parent.verticalCenter
            id: infoSection
            anchors.rightMargin: 20
            anchors.right: parent.right
            Text {
                id: currentTime
                color: Kirigami.Theme.textColor
                text: millisToMinutesAndSeconds(videoFrame.position)
            }
            Text {
                id: separator
                color: Kirigami.Theme.textColor
                text: "/"
            }
            Text {
                id: totalTime
                color: Kirigami.Theme.textColor
                text: millisToMinutesAndSeconds(videoFrame.duration)
            }
        }

    }


    Shortcut {
        sequences: ["w","Up"]
        onActivated:  (videoFrame.position + 10000 <= videoFrame.duration ? videoFrame.seek(videoFrame.position + 10000) : videoFrame.seek(videoFrame.duration))
    }
    Shortcut {
        sequences: ["Down","s"]
        onActivated: (videoFrame.position - 10000 >= 0 ? videoFrame.seek(videoFrame.position - 10000) : videoFrame.seek(0))

    }
    Shortcut {
        sequences: ["e"]
        onActivated: togglePlay()
    }


    function togglePlay(){
        if (videoFrame.playbackState === MediaPlayer.PlayingState){
            videoFrame.pause()
        }
        else{
            videoFrame.play()
        }
    }

    function millisToMinutesAndSeconds(millis) {
        var minutes = Math.floor(millis / 60000);
        var seconds = ((millis % 60000) / 1000).toFixed(0);
        return minutes + ":" + (seconds < 10 ? '0' : '') + seconds;
    }



}
