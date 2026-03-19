#!/bin/bash

# Give xrandr/i3 a moment if running on startup
sleep 1

# Get the name of the top-left active output (the one closest to x=0, y=0)
TOP_LEFT=$(i3-msg -t get_outputs | jq -r '[.[] | select(.active == true)] | sort_by(.rect.x + .rect.y) | .[0].name')

if [ -n "$TOP_LEFT" ] && [ "$TOP_LEFT" != "null" ]; then
    # Assign workspaces 1, 2, 3 to always open on the top-left monitor
    i3-msg "workspace 1 output $TOP_LEFT"
    i3-msg "workspace 2 output $TOP_LEFT"
    i3-msg "workspace 3 output $TOP_LEFT"
    
    # Move them immediately if they are already created
    i3-msg "[workspace=1] move workspace to output $TOP_LEFT"
    i3-msg "[workspace=2] move workspace to output $TOP_LEFT"
    i3-msg "[workspace=3] move workspace to output $TOP_LEFT"
fi
