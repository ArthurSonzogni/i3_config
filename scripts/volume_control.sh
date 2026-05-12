#!/bin/bash

# Auto-detect volume control tool and execute command
# Usage: volume_control.sh [up|down|mute|mic-mute] [step]

ACTION=$1
STEP=${2:-5%}

update_i3status() {
    killall -SIGUSR1 i3status 2>/dev/null
}

send_notification() {
    if command -v notify-send >/dev/null 2>&1; then
        local vol=""
        local mute=""
        
        # Get volume and mute status
        if command -v pactl >/dev/null 2>&1; then
            vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -n 1)
            mute=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -i "yes")
        elif command -v amixer >/dev/null 2>&1; then
            local output=$(amixer sget Master)
            vol=$(echo "$output" | grep -Po '\[[0-9]+%\]' | head -n 1 | tr -d '[]%')
            mute=$(echo "$output" | grep -Po '\[off\]' | head -n 1)
        fi
        
        if [ -n "$mute" ]; then
            notify-send -h string:x-canonical-private-synchronous:volume -t 1000 "Volume" "Muted"
        elif [ -n "$vol" ]; then
            notify-send -h string:x-canonical-private-synchronous:volume -t 1000 "Volume" "${vol}%"
        fi
    fi
}

# 1. Try pactl
if command -v pactl >/dev/null 2>&1; then
    case $ACTION in
        up)       pactl set-sink-volume @DEFAULT_SINK@ +"$STEP" && update_i3status ;;
        down)     pactl set-sink-volume @DEFAULT_SINK@ -"$STEP" && update_i3status ;;
        mute)     pactl set-sink-mute @DEFAULT_SINK@ toggle     && update_i3status ;;
        mic-mute) pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
    esac
    [ "$ACTION" != "mic-mute" ] && send_notification
    exit 0
fi

# 2. Try amixer
if command -v amixer >/dev/null 2>&1; then
    case $ACTION in
        up)       amixer -q sset Master "$STEP"+ unmute && update_i3status ;;
        down)     amixer -q sset Master "$STEP"- unmute && update_i3status ;;
        mute)     amixer -q sset Master toggle          && update_i3status ;;
        mic-mute) amixer -q sset Capture toggle ;;
    esac
    [ "$ACTION" != "mic-mute" ] && send_notification
    exit 0
fi

echo "No volume control tool found (pactl, amixer)" >&2
exit 1
