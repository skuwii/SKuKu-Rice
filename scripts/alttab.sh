#!/bin/bash
# Alt-Tab window switcher — manages state in /tmp/qs_alttab
# Usage: alttab.sh open | next | prev | close | cancel

ACTION=$1
STATE="/tmp/qs_alttab"

case $ACTION in
    open)
        CLIENTS=$(hyprctl clients -j 2>/dev/null | python3 -c "
import json, sys
clients = json.load(sys.stdin)
# Filter: real workspaces only (id > 0), not hidden
filtered = [c for c in clients
            if c.get('workspace', {}).get('id', -99) > 0
            and not c.get('hidden', False)]
# Sort by focusHistoryID ascending (0 = most recent)
filtered.sort(key=lambda c: c.get('focusHistoryID', 999))
result = [
    {
        'address': c['address'],
        'class':   c.get('class', ''),
        'title':   c.get('title', ''),
        'workspace': c.get('workspace', {}).get('id', 0)
    }
    for c in filtered
]
print(json.dumps(result))
")
        COUNT=$(echo "$CLIENTS" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
        if [ "$COUNT" -lt 2 ]; then
            hyprctl dispatch submap reset &>/dev/null
            exit 0
        fi
        python3 -c "
import json, sys
clients = json.loads('''$CLIENTS'''.replace(\"'\", '\"'))
" 2>/dev/null || true
        # Write initial state: index=1 (the next MRU window)
        python3 - <<PYEOF
import json
clients = $CLIENTS
state = {'action': 'open', 'clients': clients, 'index': 1}
with open('$STATE', 'w') as f:
    json.dump(state, f)
PYEOF
        ;;

    next)
        [ ! -f "$STATE" ] && exit 0
        python3 - <<PYEOF
import json
with open('$STATE') as f:
    state = json.load(f)
n = len(state['clients'])
state['index'] = (state['index'] + 1) % n
state['action'] = 'update'
with open('$STATE', 'w') as f:
    json.dump(state, f)
PYEOF
        ;;

    prev)
        [ ! -f "$STATE" ] && exit 0
        python3 - <<PYEOF
import json
with open('$STATE') as f:
    state = json.load(f)
n = len(state['clients'])
state['index'] = (state['index'] - 1) % n
state['action'] = 'update'
with open('$STATE', 'w') as f:
    json.dump(state, f)
PYEOF
        ;;

    close)
        [ ! -f "$STATE" ] && exit 0
        # Focus the selected window
        ADDR=$(python3 -c "
import json
with open('$STATE') as f:
    state = json.load(f)
clients = state['clients']
idx = state['index']
print(clients[idx]['address'] if clients else '')
")
        [ -n "$ADDR" ] && hyprctl dispatch focuswindow "address:$ADDR" &>/dev/null
        # Signal QML to hide
        python3 - <<PYEOF
import json
with open('$STATE') as f:
    state = json.load(f)
state['action'] = 'close'
with open('$STATE', 'w') as f:
    json.dump(state, f)
PYEOF
        ;;

    cancel)
        [ ! -f "$STATE" ] && exit 0
        python3 - <<PYEOF
import json
with open('$STATE') as f:
    state = json.load(f)
state['action'] = 'close'
with open('$STATE', 'w') as f:
    json.dump(state, f)
PYEOF
        ;;
esac
