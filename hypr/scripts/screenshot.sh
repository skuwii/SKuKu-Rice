#!/bin/bash
# Screenshot/recording capture backend called by ScreenshotOverlay.qml
# Usage: screenshot.sh --geometry "x,y WxH" [--edit] [--scan-qr]
#        screenshot.sh --geometry "x,y WxH" --record [--desk-mute true] [--mic-mute true] [--mic-dev device]

GEOMETRY=""
EDIT=false
RECORD=false
SCAN_QR=false
DESK_MUTE=false
MIC_MUTE=true
MIC_DEV=""
SAVE_DIR="$HOME/media/screenshots"
REC_DIR="$HOME/media/recordings"

while [[ $# -gt 0 ]]; do
    case $1 in
        --geometry)    GEOMETRY="$2"; shift 2 ;;
        --edit)        EDIT=true;  shift ;;
        --record)      RECORD=true; shift ;;
        --scan-qr)     SCAN_QR=true; shift ;;
        --desk-vol)    shift 2 ;;
        --desk-mute)   DESK_MUTE="$2"; shift 2 ;;
        --mic-vol)     shift 2 ;;
        --mic-mute)    MIC_MUTE="$2"; shift 2 ;;
        --mic-dev)     MIC_DEV="$2"; shift 2 ;;
        *) shift ;;
    esac
done

if $RECORD; then
    mkdir -p "$REC_DIR"
    FILENAME="$REC_DIR/$(date +%Y%m%d_%H%M%S).mp4"

    CMD=(wf-recorder --file "$FILENAME")
    [ -n "$GEOMETRY" ] && CMD+=(-g "$GEOMETRY")

    # Audio: prefer mic if unmuted, else desktop monitor if unmuted
    if [ "$MIC_MUTE" != "true" ] && [ -n "$MIC_DEV" ]; then
        CMD+=(-a "$MIC_DEV")
    elif [ "$DESK_MUTE" != "true" ]; then
        MONITOR=$(pactl list sources short 2>/dev/null | grep -m1 monitor | awk '{print $2}')
        [ -n "$MONITOR" ] && CMD+=(-a "$MONITOR")
    fi

    "${CMD[@]}" &
    PID=$!
    printf '{"active":true,"start":%d,"file":"%s","pid":%d}\n' \
        "$(date +%s)" "$FILENAME" "$PID" > /tmp/qs_recording
    exit 0
fi

mkdir -p "$SAVE_DIR"
FILENAME="$SAVE_DIR/$(date +%Y%m%d_%H%M%S).png"

if $SCAN_QR; then
    TMP=$(mktemp --suffix=.png)
    grim -g "$GEOMETRY" "$TMP" 2>/dev/null
    RESULT=$(zbarimg --raw -q "$TMP" 2>/dev/null | head -1)
    rm -f "$TMP"
    echo "${RESULT:-}" > /tmp/qs_qr_result
    exit 0
fi

grim -g "$GEOMETRY" "$FILENAME" 2>/dev/null || exit 1

if $EDIT; then
    swappy -f "$FILENAME"
else
    wl-copy < "$FILENAME"
    notify-send "Screenshot" "Copied to clipboard — saved to $FILENAME" -t 2000
fi
