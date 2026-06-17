#!/bin/bash

# Give xrandr/i3 a moment if running on startup
sleep 1.5

# Get all active outputs
ACTIVE_OUTPUTS=$(i3-msg -t get_outputs | jq -c '[.[] | select(.active == true)]')
NUM_OUTPUTS=$(echo "$ACTIVE_OUTPUTS" | jq '. | length')

if [ -z "$ACTIVE_OUTPUTS" ] || [ "$NUM_OUTPUTS" -eq 0 ]; then
    echo "No active output found" >&2
    exit 1
fi

CONF_FILE="$HOME/.config/i3/conf/dynamic_workspace.conf"

if [ "$NUM_OUTPUTS" -eq 3 ]; then
    # Identification logic for 3 screens:
    # BOTTOM is the one with the largest y.
    # Of the other two, TOP_LEFT is the leftmost, TOP_RIGHT is the rightmost.
    BOTTOM=$(echo "$ACTIVE_OUTPUTS" | jq -r 'sort_by(.rect.y) | last | .name')
    OTHERS=$(echo "$ACTIVE_OUTPUTS" | jq -c 'sort_by(.rect.y) | .[0:2]')
    TOP_LEFT=$(echo "$OTHERS" | jq -r 'sort_by(.rect.x) | first | .name')
    TOP_RIGHT=$(echo "$OTHERS" | jq -r 'sort_by(.rect.x) | last | .name')

    echo "3 screens detected. Top Left: $TOP_LEFT, Top Right: $TOP_RIGHT, Bottom: $BOTTOM"

    NEW_CONF=$(cat << EOF
# Generated dynamically by assign_workspaces.sh
workspace 1 output $TOP_LEFT
workspace 2 output $TOP_LEFT
workspace 3 output $TOP_LEFT
workspace 4 output $TOP_LEFT
workspace 6 output $TOP_RIGHT
workspace 7 output $TOP_RIGHT
workspace 8 output $TOP_RIGHT
workspace 9 output $TOP_RIGHT
workspace 5 output $BOTTOM
workspace 10 output $BOTTOM
EOF
)

    if [ ! -f "$CONF_FILE" ] || [ "$NEW_CONF" != "$(cat "$CONF_FILE")" ]; then
        echo "$NEW_CONF" > "$CONF_FILE"
        # Reload i3 configuration to apply the new assignments
        i3-msg reload
    fi

    # Move any already created workspaces to their designated monitors
    i3-msg "[workspace=1] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
    i3-msg "[workspace=2] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
    i3-msg "[workspace=3] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
    i3-msg "[workspace=4] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
    i3-msg "[workspace=6] move workspace to output $TOP_RIGHT" >/dev/null 2>&1 || true
    i3-msg "[workspace=7] move workspace to output $TOP_RIGHT" >/dev/null 2>&1 || true
    i3-msg "[workspace=8] move workspace to output $TOP_RIGHT" >/dev/null 2>&1 || true
    i3-msg "[workspace=9] move workspace to output $TOP_RIGHT" >/dev/null 2>&1 || true
    i3-msg "[workspace=5] move workspace to output $BOTTOM" >/dev/null 2>&1 || true
    i3-msg "[workspace=10] move workspace to output $BOTTOM" >/dev/null 2>&1 || true

else
    # Fallback behavior: Get the name of the top-left active output (prioritize leftmost, then topmost)
    TOP_LEFT=$(echo "$ACTIVE_OUTPUTS" | jq -r 'sort_by(.rect.x, .rect.y) | .[0].name')

    if [ -z "$TOP_LEFT" ] || [ "$TOP_LEFT" = "null" ]; then
        echo "No active output found" >&2
        exit 1
    fi

    echo "Not 3 screens ($NUM_OUTPUTS). Fallback to assigning 1-3 to $TOP_LEFT"

    NEW_CONF=$(cat << EOF
# Generated dynamically by assign_workspaces.sh
workspace 1 output $TOP_LEFT
workspace 2 output $TOP_LEFT
workspace 3 output $TOP_LEFT
EOF
)
    if [ ! -f "$CONF_FILE" ] || [ "$NEW_CONF" != "$(cat "$CONF_FILE")" ]; then
        echo "$NEW_CONF" > "$CONF_FILE"
        # Reload i3 configuration to apply the new assignments
        i3-msg reload
    fi

    # Move any already created workspaces 1, 2, 3 to the top-left monitor
    i3-msg "[workspace=1] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
    i3-msg "[workspace=2] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
    i3-msg "[workspace=3] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
fi
