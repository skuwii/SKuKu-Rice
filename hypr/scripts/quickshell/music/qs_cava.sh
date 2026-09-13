#!/bin/bash
# Quickshell cava bridge — writes raw semicolon-separated values to /tmp/qs_cava_bars.txt
# QML parses these and draws real Rectangle bars with animated height

config_file="/tmp/qs_cava_config"
bars_file="/tmp/qs_cava_bars.txt"
bar_count=16
flatline="$(printf '0;%.0s' $(seq "$bar_count") | sed 's/;$//')"

cat > "$config_file" << EOF
[general]
framerate = 60
bars = $bar_count
[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# A cava orphaned by a previous session keeps its monitor stream open and spins
# forever writing into a pipe nobody reads. Clear those out before starting.
# -x with -f so the whole command line must match: a plain -f substring match
# also kills any shell that merely mentions this pattern, including our own.
pkill -x -f "cava -p $config_file"

# Don't leave our own cava behind when Hyprland tears the session down.
trap 'pkill -P $$ -x cava; exit 0' TERM INT EXIT

# Supervise the pipeline. If cava exits — PipeWire restart, device switch, the
# reader end dying — the panel would otherwise stay frozen on its last frame
# until the next login, which is exactly how this broke before.
while true; do
    cava -p "$config_file" | while IFS= read -r line; do
        # Strip trailing semicolon, write raw numbers e.g. "3;5;7;2;1;4;6;3;0;5"
        printf '%s\n' "${line%;}" > "$bars_file"
    done
    printf '%s\n' "$flatline" > "$bars_file"
    sleep 2
done
