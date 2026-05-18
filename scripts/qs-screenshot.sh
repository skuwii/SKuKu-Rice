#!/bin/bash
# Launch ScreenshotOverlay.qml with restored state from previous sessions.
# Passes geometry cache, audio prefs, and mic list via env vars.

QML="$HOME/.dotfiles/hypr/scripts/quickshell/ScreenshotOverlay.qml"

CACHED_MODE=$(cat ~/.cache/qs_screenshot_mode 2>/dev/null || echo "false")
CACHED_GEOM=$(cat ~/.cache/qs_screenshot_geom 2>/dev/null || echo "")

# Get real input sources (skip loopback monitors)
MIC_LIST=$(pactl list sources 2>/dev/null | awk '
    /^Source #/           { name=""; desc="" }
    /^\s*Name:/           { name=$2 }
    /device\.description/ { match($0,"\"[^\"]+\""); desc=substr($0,RSTART+1,RLENGTH-2) }
    /^\s*State:/ && name && name !~ /\.monitor/ {
        if (desc=="") desc=name
        print name "|" desc
    }
')

# Restore audio prefs saved by the overlay on last session
PREFS=$(cat ~/.cache/qs_audio_prefs 2>/dev/null || echo "1.0,false,1.0,false,")
IFS=',' read -r DESK_VOL DESK_MUTE MIC_VOL MIC_MUTE MIC_DEV <<< "$PREFS"

QS_CACHED_MODE="$CACHED_MODE"   \
QS_CACHED_GEOM="$CACHED_GEOM"   \
QS_MIC_LIST="$MIC_LIST"         \
QS_DESK_VOL="${DESK_VOL:-1.0}"  \
QS_DESK_MUTE="${DESK_MUTE:-false}" \
QS_MIC_VOL="${MIC_VOL:-1.0}"    \
QS_MIC_MUTE="${MIC_MUTE:-false}" \
QS_MIC_DEV="${MIC_DEV:-}"       \
quickshell -p "$QML"
