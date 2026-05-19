#!/bin/bash
# Stop an active wf-recorder session and update the recording state file.

STATE="/tmp/qs_recording"

FILE=$(python3 -c "import json; d=json.load(open('$STATE')); print(d.get('file',''))" 2>/dev/null)

pkill -INT wf-recorder 2>/dev/null
sleep 0.4

printf '{"active":false}\n' > "$STATE"

[ -n "$FILE" ] && notify-send "Recording saved" "$FILE" -t 3000
