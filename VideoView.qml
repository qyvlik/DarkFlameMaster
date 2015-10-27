/*
 * Copyright (c) <2015> <copyright qyvlik>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
*/

import QtQuick 2.0
import QtMultimedia 5.4

Item {
    width: 320
    height: 240

    property alias autoLoad: mediaPlayer.autoLoad
    property alias autoPlay: mediaPlayer.autoPlay
    readonly property alias availability: mediaPlayer.availability
    readonly property alias bufferProgress: mediaPlayer.bufferProgress
    readonly property alias duration: mediaPlayer.duration
    readonly property alias error: mediaPlayer.error
    readonly property alias errorString: mediaPlayer.errorString
    readonly property alias hasAudio: mediaPlayer.hasAudio
    property alias loops: mediaPlayer.loops
    readonly property alias metaData: mediaPlayer.metaData
    property alias muted: mediaPlayer.muted
    property alias playbackRate: mediaPlayer.playbackRate
    readonly property alias playbackState: mediaPlayer.playbackState
    //! [high-precision]
    readonly property alias position: timer.position
    //! [high-precision]
    readonly property alias seekable: mediaPlayer.seekable
    property alias source: mediaPlayer.source
    readonly property alias status: mediaPlayer.status
    property alias volume: mediaPlayer.volume

    readonly property alias interval: timer.interval

    readonly property bool paused: mediaPlayer.playbackState == MediaPlayer.PausedState

    VideoOutput {
        id: videoOutput
        anchors.fill: parent

        // @disable-check M16
        autoOrientation: true
        source: mediaPlayer
    }

    MediaPlayer {
        id: mediaPlayer
        autoPlay: false
        // MediaPlayer 的 position 时间间隔不够精细
        onPlaybackStateChanged: {
            switch(mediaPlayer.playbackState)
            {
            case MediaPlayer.PlayingState:
                timer.start();break;
            case MediaPlayer.PausedState:
                timer.stop(); break;
            case MediaPlayer.StoppedState:
                timer.stop(); timer.position = 0; break;
            }
        }
    }

    Timer {
        id: timer
        interval: 80
        repeat: true
        running: false
        triggeredOnStart: false
        property int position: 0        // 毫秒
        onTriggered:{ position += interval; }
    }

    function play() {
        mediaPlayer.play();
    }

    function stop() {
        mediaPlayer.stop();
    }

    function pause() {
        mediaPlayer.pause();
    }

    function seek(offset) {
        if(mediaPlayer.seekable) {
            mediaPlayer.seek(offset);
            timer.stop();
            timer.position = offset;
            if(mediaPlayer.playbackState == MediaPlayer.PlayingState) {
                timer.start();
            }
        }
    }

    function playOrPause() {
        if(mediaPlayer.playbackState == MediaPlayer.PlayingState) {
            pause();
        } else if(mediaPlayer.playbackState == MediaPlayer.PausedState) {
            play();
        } else {
            play();
        }
    }
}

