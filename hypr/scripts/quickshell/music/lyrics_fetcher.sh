#!/usr/bin/env bash
ARTIST=$(playerctl metadata artist 2>/dev/null | head -n1)
TITLE=$(playerctl metadata title 2>/dev/null | head -n1)

if [ -z "$ARTIST" ] || [ -z "$TITLE" ]; then
    echo "No song playing."
    exit 0
fi

RESPONSE=$(curl -s -G "https://lrclib.net/api/get" \
    --data-urlencode "artist_name=${ARTIST}" \
    --data-urlencode "track_name=${TITLE}" \
    --max-time 6 2>/dev/null)

if [ -z "$RESPONSE" ]; then
    echo "Could not reach lrclib.net"
    exit 0
fi

LYRICS=$(echo "$RESPONSE" | jq -r '.plainLyrics // empty' 2>/dev/null)

if [ -z "$LYRICS" ]; then
    echo "No lyrics found for: ${ARTIST} — ${TITLE}"
else
    echo "$LYRICS"
fi
