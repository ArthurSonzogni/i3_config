#!/bin/bash

# Give xrandr/i3 a moment if running on startup
sleep 1.5

# Get the name of the top-left active output (prioritize leftmost, then topmost)
TOP_LEFT=$(i3-msg -t get_outputs | jq -r '[.[] | select(.active == true)] | sort_by(.rect.x, .rect.y) | .[0].name')

if [ -z "$TOP_LEFT" ] || [ "$TOP_LEFT" = "null" ]; then
    echo "No active output found" >&2
    exit 1
fi

CONF_FILE="$HOME/.config/i3/conf/dynamic_workspace.conf"

# Read the currently configured output in the dynamic file
CURRENT_CONFIGURED=""
if [ -f "$CONF_FILE" ]; then
    CURRENT_CONFIGURED=$(grep -Po 'workspace 1 output \K\S+' "$CONF_FILE")
fi

# If the top-left monitor has changed, update the config and reload i3
if [ "$TOP_LEFT" != "$CURRENT_CONFIGURED" ]; then
    echo "Updating top-left monitor assignment to $TOP_LEFT..."
    cat << EOF > "$CONF_FILE"
# Generated dynamically by assign_workspaces_topleft.sh
workspace 1 output $TOP_LEFT
workspace 2 output $TOP_LEFT
workspace 3 output $TOP_LEFT
EOF
    # Reload i3 configuration to apply the new assignments
    i3-msg reload
fi

# Move any already created workspaces 1, 2, 3 to the top-left monitor (fail silently if not created)
i3-msg "[workspace=1] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
i3-msg "[workspace=2] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
i3-msg "[workspace=3] move workspace to output $TOP_LEFT" >/dev/null 2>&1 || true
