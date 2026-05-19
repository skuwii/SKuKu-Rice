#!/bin/bash
# Assign a wallpaper to a workspace.
# Usage: workspace-wallpaper-set.sh [wallpaper] [workspace-id]
#   wallpaper    defaults to the currently displayed wallpaper
#   workspace-id defaults to the active workspace
# Example: workspace-wallpaper-set.sh ~/media/wallpapers/firewatch.jpg 1

CONFIG="$HOME/.config/hypr/workspace-wallpapers.json"

WALLPAPER="${1:-$(awww query 2>/dev/null | grep -oP 'image: \K\S+' | head -1)}"
WS="${2:-$(hyprctl activeworkspace -j 2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])" 2>/dev/null)}"

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    echo "Error: wallpaper not found: $WALLPAPER" >&2
    exit 1
fi

[ ! -f "$CONFIG" ] && echo '{}' > "$CONFIG"

python3 - <<PYEOF
import json
with open('$CONFIG') as f:
    cfg = json.load(f)
cfg['$WS'] = '$WALLPAPER'
with open('$CONFIG', 'w') as f:
    json.dump(cfg, f, indent=2)
print("Workspace $WS  →  $WALLPAPER")
PYEOF
