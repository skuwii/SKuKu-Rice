import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: osd

    WlrLayershell.namespace: "qs-osd"
    WlrLayershell.layer:     WlrLayer.Overlay

    anchors { bottom: true; left: true; right: true }
    margins { bottom: 64 }

    exclusionMode: ExclusionMode.Ignore
    focusable:     false
    color:         "transparent"

    implicitHeight: 72
    implicitWidth:  osd.screen.width

    // Only intercept clicks over the actual 320px widget when visible — never the full strip
    mask: Region {
        Region {
            x:      visible_ ? Math.round((osd.screen.width - 320) / 2) : 0
            y:      0
            width:  visible_ ? 320 : 0
            height: visible_ ? 72  : 0
        }
    }

    // ── State ────────────────────────────────────────────────
    property string osdType:  "volume"   // "volume" | "brightness"
    property int    osdValue: 0          // 0–100
    property bool   osdMuted: false
    property bool   visible_: false

    MatugenColors { id: _theme }

    // ── File watcher (inotifywait pattern from Main.qml) ─────
    Process {
        id: osdWatcher
        command: ["bash", "-c",
            "touch /tmp/qs_osd; " +
            "inotifywait -qq -e close_write /tmp/qs_osd 2>/dev/null; " +
            "cat /tmp/qs_osd"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let raw = this.text.trim()
                if (raw !== "") {
                    let parts = raw.split(":")
                    osd.osdType  = parts[0] || "volume"
                    osd.osdValue = parseInt(parts[1]) || 0
                    osd.osdMuted = (parts[2] === "1")
                    osd.visible_ = true
                    dismissTimer.restart()
                }
                osdWatcher.running = false
                osdWatcher.running = true
            }
        }
    }

    Timer {
        id: dismissTimer
        interval: 1800
        onTriggered: osd.visible_ = false
    }

    // ── Visuals ──────────────────────────────────────────────
    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:           parent.bottom
        width:  320
        height: 56

        opacity: osd.visible_ ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        transform: Translate {
            y: osd.visible_ ? 0 : 18
            Behavior on y {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }
        }

        // Card
        Rectangle {
            anchors.fill: parent
            radius:       16
            color:        _theme.baseGlass
            border.color: _theme.surface1
            border.width: 1

            RowLayout {
                anchors.fill:    parent
                anchors.margins: 14
                spacing:         14

                // Icon
                Text {
                    font.family:    "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    color:          osd.osdMuted ? _theme.overlay0 : _theme.blue
                    text: {
                        if (osd.osdType === "brightness")
                            return osd.osdValue > 50 ? "󰃠" : "󰃟"
                        if (osd.osdMuted || osd.osdValue === 0) return "󰖁"
                        return osd.osdValue > 50 ? "󰕾" : "󰖀"
                    }
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                // Bar track
                Rectangle {
                    Layout.fillWidth: true
                    height:           6
                    radius:           3
                    color:            _theme.surface1

                    Rectangle {
                        width:  parent.width * (osd.osdValue / 100)
                        height: parent.height
                        radius: parent.radius
                        color:  osd.osdMuted ? _theme.overlay0 : _theme.blue
                        Behavior on width {
                            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                    }
                }

                // Percentage
                Text {
                    text:           osd.osdMuted ? "muted" : (osd.osdValue + "%")
                    font.family:    "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.weight:    Font.Medium
                    color:          osd.osdMuted ? _theme.overlay0 : _theme.text
                    Layout.minimumWidth: 46
                    horizontalAlignment: Text.AlignRight
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }
        }
    }
}
