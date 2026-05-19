import QtQuick
import QtQuick.Layouts
import Quickshell
import "../"

Item {
    id: window

    // Required by Main.qml's StackView loader
    property real layoutWidth:  width
    property real layoutHeight: height
    property var  notifModel:   null

    Scaler { id: scaler; currentWidth: Screen.width }
    function s(val) { return scaler.s(val) }

    MatugenColors { id: _theme }

    Component.onCompleted: SysData.subscribe()
    Component.onDestruction: SysData.unsubscribe()

    // ── History buffers (last 40 ticks) ──────────────────────
    property int histMax: 40
    property var cpuHist:  []
    property var rxHist:   []
    property var txHist:   []
    property var gpuHist:  []
    property var diskRHist: []
    property var diskWHist: []

    function push(arr, val) {
        let a = arr.slice()
        a.push(val)
        if (a.length > histMax) a.shift()
        return a
    }

    Connections {
        target: SysData
        function onCpuChanged()  { window.cpuHist   = window.push(window.cpuHist,   SysData.cpu) }
        function onNetRxChanged(){ window.rxHist    = window.push(window.rxHist,    SysData.netRx) }
        function onNetTxChanged(){ window.txHist    = window.push(window.txHist,    SysData.netTx) }
        function onGpuUtilChanged(){ window.gpuHist = window.push(window.gpuHist,   SysData.gpuUtil) }
        function onDiskRChanged(){ window.diskRHist = window.push(window.diskRHist, SysData.diskR) }
        function onDiskWChanged(){ window.diskWHist = window.push(window.diskWHist, SysData.diskW) }
    }

    function fmtBytes(b) {
        if (b < 1024)        return b.toFixed(0) + " B/s"
        if (b < 1024*1024)   return (b/1024).toFixed(1) + " KB/s"
        return (b/1024/1024).toFixed(1) + " MB/s"
    }

    // ── Root scroll area ─────────────────────────────────────
    Flickable {
        anchors.fill: parent
        anchors.margins: s(16)
        contentWidth: width
        contentHeight: col.implicitHeight
        clip: true

        Column {
            id: col
            width: parent.width
            spacing: s(12)

            // ── Section: CPU & RAM ────────────────────────────
            SectionCard {
                width: parent.width
                title: "CPU & Memory"

                Column {
                    width: parent.width
                    spacing: s(10)

                    StatRow {
                        label:   "CPU"
                        value:   SysData.cpu + "%"
                        fill:    SysData.cpu / 100
                        accent:  SysData.cpu > 80 ? _theme.red : (SysData.cpu > 50 ? _theme.peach : _theme.blue)
                        history: window.cpuHist
                    }

                    StatRow {
                        label: "RAM"
                        value: SysData.ramGb.toFixed(1) + " GB"
                        fill:  SysData.ramPercent / 100
                        accent: SysData.ramPercent > 80 ? _theme.red : (SysData.ramPercent > 60 ? _theme.peach : _theme.blue)
                        history: []
                    }

                    StatRow {
                        label: "CPU Temp"
                        value: SysData.temp + "°C"
                        fill:  Math.min(SysData.temp / 100, 1.0)
                        accent: SysData.temp > 85 ? _theme.red : (SysData.temp > 70 ? _theme.peach : _theme.teal)
                        history: []
                    }
                }
            }

            // ── Section: GPU ──────────────────────────────────
            SectionCard {
                width: parent.width
                title: "GPU  (RTX 3060 · " + SysData.gpuTemp + "°C)"
                visible: SysData.gpuVramTotal > 0

                Column {
                    width: parent.width
                    spacing: s(10)

                    StatRow {
                        label:   "Utilisation"
                        value:   SysData.gpuUtil + "%"
                        fill:    SysData.gpuUtil / 100
                        accent:  SysData.gpuUtil > 80 ? _theme.red : (SysData.gpuUtil > 50 ? _theme.peach : _theme.blue)
                        history: window.gpuHist
                    }

                    StatRow {
                        label: "VRAM"
                        value: (SysData.gpuVramUsed / 1024).toFixed(1) + " / " +
                               (SysData.gpuVramTotal / 1024).toFixed(0) + " GB"
                        fill:  SysData.gpuVramTotal > 0 ? SysData.gpuVramUsed / SysData.gpuVramTotal : 0
                        accent: _theme.blue
                        history: []
                    }
                }
            }

            // ── Section: Network ──────────────────────────────
            SectionCard {
                width: parent.width
                title: "Network"

                Column {
                    width: parent.width
                    spacing: s(10)

                    StatRow {
                        label:     "↓  Down"
                        value:     window.fmtBytes(SysData.netRx)
                        fill:      0
                        accent:    _theme.teal
                        history:   window.rxHist
                        histColor: _theme.teal
                        histPct:   false
                    }

                    StatRow {
                        label:     "↑  Up"
                        value:     window.fmtBytes(SysData.netTx)
                        fill:      0
                        accent:    _theme.sapphire
                        history:   window.txHist
                        histColor: _theme.sapphire
                        histPct:   false
                    }
                }
            }

            // ── Section: Disk ─────────────────────────────────
            SectionCard {
                width: parent.width
                title: "Disk I/O"

                Column {
                    width: parent.width
                    spacing: s(10)

                    StatRow {
                        label:     "Read"
                        value:     window.fmtBytes(SysData.diskR)
                        fill:      0
                        accent:    _theme.green
                        history:   window.diskRHist
                        histColor: _theme.green
                        histPct:   false
                    }

                    StatRow {
                        label:     "Write"
                        value:     window.fmtBytes(SysData.diskW)
                        fill:      0
                        accent:    _theme.yellow
                        history:   window.diskWHist
                        histColor: _theme.yellow
                        histPct:   false
                    }
                }
            }
        }
    }

    // ── Reusable components ───────────────────────────────────

    component SectionCard: Item {
        id: card
        property string title: ""
        default property alias content: innerCol.data
        implicitHeight: hdr.implicitHeight + innerCol.implicitHeight + s(28)

        Rectangle {
            anchors.fill: parent
            color:        _theme.surface0
            radius:       s(10)
            border.color: _theme.surface1
            border.width: 1
        }

        Text {
            id: hdr
            anchors { top: parent.top; left: parent.left; margins: s(12) }
            text:           card.title
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: s(12)
            font.weight:    Font.Medium
            color:          _theme.overlay2
        }

        Column {
            id: innerCol
            anchors { top: hdr.bottom; left: parent.left; right: parent.right
                      margins: s(12); topMargin: s(8) }
            spacing: s(10)
        }
    }

    component StatRow: Item {
        id: row
        property string label:     ""
        property string value:     ""
        property real   fill:      0.0          // 0.0–1.0 for the bar; ignored if history is set
        property color  accent:    _theme.blue
        property var    history:   []
        property color  histColor: accent
        property bool   histPct:   true          // true = history values are 0–100; false = auto-scale to peak
        implicitHeight: s(34)
        implicitWidth:  parent ? parent.width : 300

        readonly property real histPeak: {
            let m = 1
            for (let i = 0; i < history.length; i++) if (history[i] > m) m = history[i]
            return m
        }

        // Label
        Text {
            id: lbl
            anchors.verticalCenter: parent.verticalCenter
            width:          s(80)
            text:           row.label
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: s(12)
            color:          _theme.overlay2
        }

        // Value
        Text {
            id: val
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            width:               s(90)
            text:                row.value
            font.family:         "JetBrainsMono Nerd Font"
            font.pixelSize:      s(12)
            font.weight:         Font.Medium
            color:               row.accent
            horizontalAlignment: Text.AlignRight
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        // Bar track (only shown when fill > 0 from a stat with a natural 0-100% range)
        Rectangle {
            id: track
            anchors {
                left:  lbl.right; leftMargin: s(8)
                right: val.left;  rightMargin: s(8)
                verticalCenter: parent.verticalCenter
            }
            height:  s(6)
            radius:  s(3)
            color:   _theme.surface1
            visible: row.history.length === 0

            Rectangle {
                width:  parent.width * Math.min(row.fill, 1.0)
                height: parent.height
                radius: parent.radius
                color:  row.accent
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation  { duration: 200 } }
            }
        }

        // Sparkline history graph (shown when history array is present)
        Row {
            anchors {
                left:  lbl.right; leftMargin: s(8)
                right: val.left;  rightMargin: s(8)
                verticalCenter: parent.verticalCenter
            }
            height:  s(24)
            spacing: 1
            visible: row.history.length > 0

            Repeater {
                model: row.history.length > 0 ? row.history : [0]
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width:  Math.max(2, (parent.width - row.history.length) / Math.max(row.history.length, 1))
                    height: parent.height
                    color:  "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width:          parent.width
                        height:         Math.max(2, parent.height * Math.min(
                                            row.histPct ? modelData / 100 : modelData / row.histPeak, 1.0))
                        radius:         1
                        color:          Qt.rgba(row.histColor.r, row.histColor.g, row.histColor.b,
                                                0.3 + 0.7 * (index / Math.max(row.history.length - 1, 1)))
                        Behavior on height { NumberAnimation { duration: 150 } }
                    }
                }
            }
        }
    }
}
