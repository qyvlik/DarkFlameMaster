# DarkFlameMaster

Dark Flame Master.

Such as niconico or bilibili's player, can bullet the commit on the screen with playing video.

取个中二点的名字。其实是个使用 QML 实现的弹幕播放器。

## 弹幕的抽象

弹幕文件最为基本信息是：

1. 弹幕内容

2. 弹幕的视频时间戳

3. 弹幕发送的时间戳

4. 弹幕字体大小

5. 弹幕字体颜色

6. 弹幕类型（诸如高级弹幕，滚动弹幕，悬停弹幕，逆滚弹幕）

由于 `Qt` 媒体类实现的问题，播放进度的 `position` 只能以一秒为间隔进行更新。

## 改进的 `VideoView`

由于 `Qt` 中媒体类的实现问题，其进度属性 `position` 不可能实时更新，一般是以 1 秒的间隔进行更新。

但是弹幕的视频时间戳，其精度十分高，也就是时间间隔十分小，小于 100 ms，这个精度远高于 `QtMultiMedia` 模块中的 `MediaPlayer` 的时间精度。

为改进现有的 `MediaPlayer`，使其输出的 `postition` 精度提高。可以内置一个 `Timer`，当多媒体播放的时候，启动定时器，定时器精度设置为 100 ms 便会每隔 100 ms 更新 `postition`。

```
    readonly property int postition: timer.postiton
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
```

这样就可以输出时间间隔精度可以调控的 `postition`。

另一个是使用约等于来处理低精度定时器时间匹配的问题。

```js
function approximate(a, b, d) {
    d = d || 0.005;
    return Math.abs(a-b) < d;
}
``` 

## 弹幕层的简单实现

弹幕层的实现和简单。在 `VideoView` 设置一层弹幕层，有利于弹幕的隐藏于实现。

先看看弹幕层的简单实现。

```
//: DanmuLayer.qml
import QtQuick 2.0

Item {
    id: layer

    width: 320
    height: 240
    property bool paused: false

    Component {
        id: danmuComponent
        Text {
            id: text

            property alias fontPointSize: text.font.pointSize
            property alias paused: animation.paused
            property alias duration: animation.duration

            NumberAnimation on x {
                id: animation
                alwaysRunToEnd: true
                duration: 3000
                to: -text.contentWidth
            }
            onXChanged: {
                if(x <= -text.contentWidth) {
                    text.destroy();
                }
            }
        }
    }

    function shoot(text) {
        var danmu =
                danmuComponent.
        createObject(layer, {
                         x: Qt.binding(function(){return layer.width;}),
                         text: text,
                         paused:Qt.binding(function(){return layer.paused;}),
                         visible:Qt.binding(function(){return layer.visible;}),
                         color: "white",
                         fontPointSize: 25,
                         duration: 3000
                     });
    }
}
```

由于 `danmuComponent` 中多项属性绑定到了 `DanmuLayer` 的属性，当 `DanmuLayer` 属性改变的时候，可以轻松的控制到 `DanmuLayer` 中的弹幕，例如停止弹幕，隐藏弹幕等操作。

## 弹幕播放器的整合

TODO

---

[弹幕播放器中的时间轴算法](http://blog.sina.com.cn/s/blog_630555440100ueju.html)