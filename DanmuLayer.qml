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

