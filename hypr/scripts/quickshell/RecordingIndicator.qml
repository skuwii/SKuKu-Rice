import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    WlrLayershell.namespace: "qs-recording"
    WlrLayershell.layer:     WlrLayer.Overlay

    anchors { top: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    focusable:     false
    color:         "transparent"
    visible:       root.recording

    implicitHeight: s(52)

    property bool   recording:  false
    property int    startTime:  0

    MatugenColors { id: _theme }
    Scaler { id: scaler; currentWidth: Screen.width }
    function s(v) { return scaler.s(v) }

    Timer {
        interval: 1000
        running:  root.recording
        repeat:   true
        onTriggered: elapsed.tick()
    }

    Process {
        id: watcher
        command: ["bash", "-c",
            "touch /tmp/qs_recording; " +
            "inotifywait -qq -e close_write /tmp/qs_recording 2>/dev/null; " +
            "cat /tmp/qs_recording"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let raw = this.text.trim()
                if (raw !== "") {
                    try {
                        let d = JSON.parse(raw)
                        root.recording = d.active === true
                        root.startTime = d.start  || 0
                        elapsed.seconds = 0
                    } catch(e) {}
                }
                watcher.running = false
                watcher.running = true
            }
        }
    }

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:              parent.top
        anchors.topMargin:        s(8)
        width:  pill.width
        height: pill.height

        Rectangle {
            id: pill
            width:  row.implicitWidth + s(28)
            height: s(34)
            radius: s(17)
            color:  Qt.rgba(0.06, 0.04, 0.04, 0.92)
            border.color: Qt.rgba(_theme.red.r, _theme.red.g, _theme.red.b, 0.45)
            border.width: 1

            layer.enabled: true
            layer.effect: null

            transform: Translate {
                y: root.recording ? 0 : -s(52)
                Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            }
            opacity: root.recording ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }

            RowLayout {
                id: row
                anchors.centerIn: parent
                spacing: s(8)

                // Pulsing dot
                Rectangle {
                    width:  s(8)
                    height: s(8)
                    radius: s(4)
                    color:  _theme.red
                    Layout.alignment: Qt.AlignVCenter

                    SequentialAnimation on opacity {
                        running: root.recording
                        loops:   Animation.Infinite
                        NumberAnimation { to: 0.25; duration: 700; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0;  duration: 700; easing.type: Easing.InOutSine }
                    }
                }

                Text {
                    text:           "REC"
                    font.family:    "JetBrainsMono Nerd Font"
                    font.pixelSize: s(11)
                    font.weight:    Font.Bold
                    color:          _theme.red
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    id: elapsed
                    property int seconds: 0
                    function tick() {
                        seconds = root.startTime > 0
                            ? Math.floor(Date.now() / 1000) - root.startTime
                            : seconds + 1
                    }
                    text: {
                        let s = seconds % 60
                        let m = Math.floor(seconds / 60) % 60
                        let h = Math.floor(seconds / 3600)
                        return (h > 0 ? h + ":" : "") +
                               (m < 10 ? "0" : "") + m + ":" +
                               (s < 10 ? "0" : "") + s
                    }
                    font.family:    "JetBrainsMono Nerd Font"
                    font.pixelSize: s(12)
                    font.weight:    Font.Medium
                    color:          _theme.text
                    Layout.alignment: Qt.AlignVCenter
                }

                Rectangle {
                    width:  1
                    height: s(14)
                    color:  _theme.surface1
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text:           "⊞+⇧+R to stop"
                    font.family:    "JetBrainsMono Nerd Font"
                    font.pixelSize: s(10)
                    color:          _theme.overlay1
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}
