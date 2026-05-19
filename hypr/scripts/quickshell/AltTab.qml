import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    WlrLayershell.namespace: "qs-alttab"
    WlrLayershell.layer:     WlrLayer.Overlay

    anchors { top: true; bottom: true; left: true; right: true }

    exclusionMode: ExclusionMode.Ignore
    focusable:     false
    color:         "transparent"
    visible:       root.visible_

    implicitHeight: root.screen.height
    implicitWidth:  root.screen.width

    property var    clients:       []
    property int    selectedIndex: 0
    property bool   visible_:      false

    MatugenColors { id: _theme }

    // ── File watcher ─────────────────────────────────────────
    Process {
        id: watcher
        command: ["bash", "-c",
            "touch /tmp/qs_alttab; " +
            "inotifywait -qq -e close_write /tmp/qs_alttab 2>/dev/null; " +
            "cat /tmp/qs_alttab"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let raw = this.text.trim()
                if (raw !== "") {
                    try {
                        let data = JSON.parse(raw)
                        if (data.action === "close") {
                            root.visible_ = false
                        } else {
                            root.clients       = data.clients  || []
                            root.selectedIndex = data.index    || 0
                            root.visible_      = true
                        }
                    } catch (e) {}
                }
                watcher.running = false
                watcher.running = true
            }
        }
    }

    // ── Scrim ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color:        "#44000000"
        opacity:      root.visible_ ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // ── Switcher card ─────────────────────────────────────────
    Item {
        id:               card
        anchors.centerIn: parent
        width:  Math.min(root.clients.length * 104 + 32, root.screen.width - 80)
        height: 128

        opacity: root.visible_ ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        transform: Scale {
            origin.x: card.width / 2
            origin.y: card.height / 2
            xScale:   root.visible_ ? 1.0 : 0.88
            yScale:   root.visible_ ? 1.0 : 0.88
            Behavior on xScale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on yScale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        }

        // Card background
        Rectangle {
            anchors.fill: parent
            radius:       18
            color:        _theme.baseGlass
            border.color: _theme.surface1
            border.width: 1

            // Window items
            Row {
                anchors.centerIn: parent
                spacing:          8

                Repeater {
                    model: root.clients

                    delegate: Item {
                        width:  96
                        height: 104
                        required property var  modelData
                        required property int  index

                        readonly property bool isSelected: index === root.selectedIndex

                        // Selection highlight
                        Rectangle {
                            anchors.fill:    parent
                            anchors.margins: 2
                            radius:          12
                            color:           parent.isSelected ? Qt.rgba(
                                                 _theme.blue.r, _theme.blue.g, _theme.blue.b, 0.18
                                             ) : "transparent"
                            border.color:    parent.isSelected ? _theme.blue : "transparent"
                            border.width:    1
                            Behavior on color        { ColorAnimation  { duration: 100 } }
                            Behavior on border.color { ColorAnimation  { duration: 100 } }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing:          6

                            // App icon
                            Image {
                                id:          appIcon
                                width:       52
                                height:      52
                                anchors.horizontalCenter: parent.horizontalCenter
                                source:      "image://icon/" + modelData.class
                                fillMode:    Image.PreserveAspectFit
                                smooth:      true
                                visible:     status === Image.Ready

                                Behavior on opacity { NumberAnimation { duration: 80 } }
                            }

                            // Fallback icon (nerd font)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width:       52
                                height:      52
                                visible:     appIcon.status !== Image.Ready
                                text:        ""
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 32
                                color:       _theme.overlay2
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment:   Text.AlignVCenter
                            }

                            // App title
                            Text {
                                width:               88
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:                modelData.title.length > 14
                                                         ? modelData.title.substring(0, 13) + "…"
                                                         : modelData.title
                                font.family:         "JetBrainsMono Nerd Font"
                                font.pixelSize:      11
                                font.weight:         parent.parent.isSelected ? Font.Medium : Font.Normal
                                color:               parent.parent.isSelected ? _theme.text : _theme.overlay2
                                horizontalAlignment: Text.AlignHCenter
                                elide:               Text.ElideRight
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }
                        }
                    }
                }
            }
        }
    }
}
