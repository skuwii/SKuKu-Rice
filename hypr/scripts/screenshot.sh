#!/bin/bash
# Screenshot capture backend called by ScreenshotOverlay.qml
# Usage: screenshot.sh --geometry "x,y WxH" [--edit] [--scan-qr]
#        screenshot.sh --record ... (stub — wf-recorder not installed)

GEOMETRY=""
EDIT=false
RECORD=false
SCAN_QR=false
SAVE_DIR="$HOME/media/screenshots"
mkdir -p "$SAVE_DIR"

while [[ $# -gt 0 ]]; do
    case $1 in
        --geometry)    GEOMETRY="$2"; shift 2 ;;
        --edit)        EDIT=true;  shift ;;
        --record)      RECORD=true; shift ;;
        --scan-qr)     SCAN_QR=true; shift ;;
        # audio flags for recording (consumed but unused until wf-recorder arrives)
        --desk-vol|--desk-mute|--mic-vol|--mic-mute|--mic-dev) shift 2 ;;
        *) shift ;;
    esac
done

if $RECORD; then
    notify-send "Recording" "wf-recorder not installed — install it to enable screen recording" -t 3000
    exit 0
fi

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
