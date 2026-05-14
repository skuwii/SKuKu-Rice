import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// STR Left Panel — Quickshell port of eww dionysus_panel
PanelWindow {
    id: panel

    WlrLayershell.namespace: "qs-left-panel"
    WlrLayershell.layer:     WlrLayer.Bottom

    anchors { left: true; top: true; bottom: true; right: false }
    margins { left: 20; top: 68; bottom: 20 }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    implicitWidth: 360

    // ── STR PALETTE ──────────────────────────────────────────────────────
    readonly property color clrCrust:   "#0e0f11"
    readonly property color clrBase:    "#1c1e21"
    readonly property color clrSurf0:   "#25272a"
    readonly property color clrSurf1:   "#2e3136"
    readonly property color clrText:    "#d6d8dc"
    readonly property color clrDim:     "#8a8d92"
    readonly property color clrMute:    "#4f5258"
    readonly property color clrAzure:   "#2980d4"
    readonly property color clrAzureHi: "#4ea0e8"
    readonly property color clrPink:    "#ffb8c6"
    readonly property color clrLove:    "#d4608a"

    // Shared card background — 0.82 opacity shows cleanly against dark Firewatch wallpaper
    readonly property color cardBg: Qt.rgba(28/255, 30/255, 33/255, 0.82)

    // ── CLOCK ────────────────────────────────────────────────────────────
    property string clockTime: Qt.formatTime(new Date(), "HH:mm")
    property string clockDate: Qt.formatDate(new Date(), "ddd, MMM d").toUpperCase()

    Timer {
        interval: 1000; repeat: true; running: true
        onTriggered: {
            panel.clockTime = Qt.formatTime(new Date(), "HH:mm");
            panel.clockDate = Qt.formatDate(new Date(), "ddd, MMM d").toUpperCase();
        }
    }

    // ── LOVE COUNTER ─────────────────────────────────────────────────────
    readonly property int loveDays: Math.floor(
        (Date.now() - new Date("2025-04-02").getTime()) / 86400000
    )

    // ── SYSTEM DATA ──────────────────────────────────────────────────────
    property int sysCpu:  0
    property int sysRam:  0
    property int sysTemp: 0
    property int sysDisk: 0

    Process {
        id: sysPoller
        command: ["bash", "-c", "bash ~/.config/hypr/scripts/quickshell/watchers/sys_fetcher.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var p = this.text.trim().split("|");
                if (p.length >= 4) {
                    panel.sysCpu  = parseInt(p[0]) || 0;
                    panel.sysRam  = parseInt(p[1]) || 0;
                    panel.sysTemp = parseInt(p[3]) || 0;
                }
            }
        }
    }

    Process {
        id: diskPoller
        running: true
        command: ["bash", "-c", "df / | awk 'NR==2{gsub(\"%\",\"\");print $5}'"]
        stdout: StdioCollector {
            onStreamFinished: { panel.sysDisk = parseInt(this.text.trim()) || 0; }
        }
    }

    Timer { interval: 2000;  repeat: true; running: true; onTriggered: { sysPoller.running = false; sysPoller.running = true; } }
    Timer { interval: 60000; repeat: true; running: true; onTriggered: { diskPoller.running = false; diskPoller.running = true; } }

    // ── MEDIA DATA ───────────────────────────────────────────────────────
    property string mediaTitle:  "Not Playing"
    property string mediaArtist: ""
    property string mediaArt:    ""
    property string mediaStatus: "Stopped"

    Process {
        id: musicPoller
        command: ["bash", "-c", "bash ~/.config/hypr/scripts/quickshell/music/music_info.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var d = JSON.parse(this.text.trim());
                    panel.mediaStatus = d.status  || "Stopped";
                    panel.mediaTitle  = d.title   || "Not Playing";
                    panel.mediaArtist = d.artist  || "";
                    panel.mediaArt    = d.artUrl  || "";
                } catch(e) {}
            }
        }
    }

    Timer { interval: 3000; repeat: true; running: true; onTriggered: { musicPoller.running = false; musicPoller.running = true; } }

    // ── CAVA BARS ────────────────────────────────────────────────────────
    property var cavaBarsData: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    Process {
        id: cavaPoller
        command: ["bash", "-c", "cat /tmp/qs_cava_bars.txt 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var t = this.text.trim();
                if (t.length > 0) {
                    var vals = t.split(";").map(function(s) { return parseInt(s) || 0; });
                    if (vals.length > 0) panel.cavaBarsData = vals;
                }
            }
        }
    }

    Timer { interval: 50; repeat: true; running: true; onTriggered: { cavaPoller.running = false; cavaPoller.running = true; } }

    // ── INLINE COMPONENTS ────────────────────────────────────────────────

    // Card: shared glass card base — 0.82 opacity, hairline white border, top-edge highlight
    component Card: Rectangle {
        Layout.fillWidth: true
        radius: 18
        color: panel.cardBg
        border { color: Qt.rgba(1, 1, 1, 0.08); width: 1 }
        // Glass top-edge catch light
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1; radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.10)
            z: 10
        }
    }

    // SysBar: label + value + animated progress bar
    component SysBar: ColumnLayout {
        required property string label
        required property int    value
        required property color  barColor

        Layout.fillWidth: true
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: label
                font { family: "JetBrains Mono"; pixelSize: 12; bold: true }
                color: panel.clrText
            }
            Item { Layout.fillWidth: true }
            Text {
                text: value + "%"
                font { family: "JetBrains Mono"; pixelSize: 12 }
                color: panel.clrDim
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 8; radius: 4
            color: Qt.rgba(46/255, 49/255, 54/255, 0.8)

            Rectangle {
                width: parent.width * Math.min(value / 100, 1)
                height: parent.height; radius: 4
                color: barColor
                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
            }
        }
    }

    // ── LAYOUT ───────────────────────────────────────────────────────────
    Flickable {
        anchors.fill: parent
        contentHeight: mainCol.implicitHeight
        clip: true
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 15

            // ── 1. PROFILE ───────────────────────────────────────────────
            Card {
                implicitHeight: 88

                RowLayout {
                    anchors { fill: parent; margins: 20 }
                    spacing: 15

                    // S avatar
                    Rectangle {
                        width: 48; height: 48; radius: 24
                        color: panel.clrAzure
                        border { color: Qt.rgba(41/255, 128/255, 212/255, 0.45); width: 2 }
                        Text {
                            anchors.centerIn: parent
                            text: "S"
                            font { family: "JetBrainsMono Nerd Font"; pixelSize: 28; bold: true }
                            color: panel.clrCrust
                        }
                    }

                    // Name block
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: "skuwii"
                            font { family: "JetBrains Mono"; pixelSize: 15; bold: true }
                            color: panel.clrText
                        }
                        Text {
                            text: "yousef-arch"
                            font { family: "JetBrains Mono"; pixelSize: 15 }
                            color: panel.clrDim
                        }
                    }

                    // M ♥ Y chip
                    Rectangle {
                        implicitWidth: eggRow.implicitWidth + 24
                        height: 32; radius: 30
                        color: Qt.rgba(37/255, 39/255, 42/255, 0.95)
                        border { color: Qt.rgba(255/255, 184/255, 198/255, 0.25); width: 1 }
                        RowLayout {
                            id: eggRow
                            anchors.centerIn: parent
                            spacing: 0
                            Text {
                                text: "M "
                                font.family: "JetBrains Mono"; font.pixelSize: 18; font.bold: true
                                color: panel.clrText
                            }
                            Text {
                                text: "♥ "
                                font.family: "JetBrains Mono"; font.pixelSize: 20
                                color: panel.clrPink
                            }
                            Text {
                                text: "Y"
                                font.family: "JetBrains Mono"; font.pixelSize: 18; font.bold: true
                                color: panel.clrText
                            }
                        }
                    }
                }
            }

            // ── 2. CLOCK ─────────────────────────────────────────────────
            Card {
                implicitHeight: 114

                RowLayout {
                    anchors { fill: parent; margins: 10 }
                    spacing: 0

                    // Clock + date
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        Text {
                            text: panel.clockTime
                            font { family: "JetBrains Mono"; pixelSize: 52; weight: Font.Black }
                            color: panel.clrText
                        }
                        Text {
                            text: panel.clockDate
                            font { family: "JetBrains Mono"; pixelSize: 18; bold: true }
                            color: panel.clrAzureHi
                        }
                    }

                    // Weather — right-aligned column
                    ColumnLayout {
                        spacing: 8
                        Text {
                            text: "🌙"
                            font.pixelSize: 28
                            Layout.alignment: Qt.AlignRight
                        }
                        Text {
                            text: "28°C"
                            font { family: "JetBrains Mono"; pixelSize: 13; bold: true }
                            color: panel.clrText
                            Layout.alignment: Qt.AlignRight
                        }
                        Text {
                            text: "Jeddah, SA"
                            font { family: "JetBrains Mono"; pixelSize: 10 }
                            color: panel.clrDim
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }

            // ── 3. SYS GRID ──────────────────────────────────────────────
            Card {
                implicitHeight: 132

                ColumnLayout {
                    anchors { fill: parent; margins: 20 }
                    spacing: 15

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        SysBar { label: "CPU";  value: panel.sysCpu;  barColor: panel.clrAzure }
                        SysBar { label: "RAM";  value: panel.sysRam;  barColor: panel.clrAzure }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        SysBar { label: "SSD";  value: panel.sysDisk; barColor: panel.clrAzure }
                        SysBar { label: "TEMP"; value: panel.sysTemp; barColor: panel.clrPink  }
                    }
                }
            }

            // ── 4. FETCH ─────────────────────────────────────────────────
            Card {
                implicitHeight: 140

                ColumnLayout {
                    anchors { fill: parent; margins: 20 }
                    spacing: 8

                    Text {
                        text: "STR TERMINAL INFO"
                        font { family: "JetBrains Mono"; pixelSize: 10; bold: true; letterSpacing: 2 }
                        color: panel.clrMute
                        Layout.bottomMargin: 4
                    }

                    Repeater {
                        model: [
                            { icon: "",         title: "OS:",   val: "Arch Linux"  },
                            { icon: "",         title: "WM:",   val: "Hyprland"    },
                            { icon: "",   title: "Term:", val: "Kitty / ZSH" }
                        ]
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            Text {
                                text: modelData.icon
                                font { family: "JetBrainsMono Nerd Font"; pixelSize: 16 }
                                color: panel.clrAzureHi
                                Layout.minimumWidth: 22
                            }
                            Text {
                                text: modelData.title
                                font { family: "JetBrains Mono"; pixelSize: 12 }
                                color: panel.clrDim
                            }
                            Text {
                                text: modelData.val
                                font { family: "JetBrains Mono"; pixelSize: 12 }
                                color: panel.clrText
                            }
                        }
                    }
                }
            }

            // ── 5. MEDIA ─────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 226
                radius: 12
                color: Qt.rgba(0.11, 0.12, 0.18, 0.90)
                border { color: Qt.rgba(1, 1, 1, 0.06); width: 1 }

                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 1; radius: parent.radius
                    color: Qt.rgba(1, 1, 1, 0.10); z: 10
                }

                ColumnLayout {
                    anchors { fill: parent; margins: 15 }
                    spacing: 10

                    // Album art + track info
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Rectangle {
                            width: 80; height: 80; radius: 8
                            color: Qt.rgba(1, 1, 1, 0.04)
                            clip: true
                            Image {
                                anchors.fill: parent
                                source: panel.mediaArt !== "" ? "file://" + panel.mediaArt : ""
                                fillMode: Image.PreserveAspectCrop
                                visible: status === Image.Ready
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Text {
                                Layout.fillWidth: true
                                text: panel.mediaTitle
                                font { family: "JetBrains Mono"; pixelSize: 13; bold: true }
                                color: panel.clrText
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: panel.mediaArtist
                                font { family: "JetBrains Mono"; pixelSize: 11 }
                                color: panel.clrDim
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                spacing: 20
                                Repeater {
                                    model: [
                                        { icon: "⏮", cmd: "previous"   },
                                        { icon: "⏸", cmd: "play-pause" },
                                        { icon: "⏭", cmd: "next"       }
                                    ]
                                    delegate: Text {
                                        text: modelData.icon
                                        font.pixelSize: 20
                                        color: panel.clrAzureHi
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: Quickshell.execDetached(["playerctl", modelData.cmd])
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Cava terminal box
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 90
                        radius: 6
                        color: Qt.rgba(0.04, 0.05, 0.08, 0.92)
                        border { color: panel.clrAzureHi; width: 2 }
                        clip: true

                        Row {
                            anchors { fill: parent; margins: 8 }
                            spacing: 3

                            Repeater {
                                model: panel.cavaBarsData.length
                                delegate: Item {
                                    width: (parent.width - (panel.cavaBarsData.length - 1) * 3) / panel.cavaBarsData.length
                                    height: parent.height

                                    Rectangle {
                                        width: parent.width
                                        height: Math.max(2, parent.height * (panel.cavaBarsData[index] / 7))
                                        anchors.bottom: parent.bottom
                                        radius: 2
                                        color: panel.clrAzureHi

                                        Behavior on height {
                                            NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── 6. LOVE ──────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 14
                color: panel.cardBg
                border { color: Qt.rgba(0.75, 0.08, 0.48, 0.15); width: 1 }

                // Subtle pink top highlight instead of white
                Rectangle {
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 1; radius: parent.radius
                    color: Qt.rgba(192/255, 57/255, 122/255, 0.18)
                    z: 10
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        topMargin: 10; bottomMargin: 10
                        leftMargin: 14; rightMargin: 14
                    }
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "♥"; font.pixelSize: 10; color: Qt.rgba(0.75, 0.08, 0.48, 0.22) }
                        Item { Layout.fillWidth: true }
                        Text { text: "♥"; font.pixelSize: 10; color: Qt.rgba(0.75, 0.08, 0.48, 0.22) }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: panel.loveDays.toString()
                        font { family: "JetBrains Mono"; pixelSize: 38; bold: true }
                        color: panel.clrLove
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "DAYS TOGETHER"
                        font { family: "JetBrains Mono"; pixelSize: 8; bold: true; letterSpacing: 4 }
                        color: Qt.rgba(0.83, 0.38, 0.54, 0.5)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "♥"; font.pixelSize: 10; color: Qt.rgba(0.75, 0.08, 0.48, 0.22) }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "M · Y"
                            font { family: "JetBrains Mono"; pixelSize: 7 }
                            color: Qt.rgba(0.75, 0.08, 0.48, 0.12)
                        }
                    }
                }
            }

            Item { implicitHeight: 8 }
        }
    }
}
