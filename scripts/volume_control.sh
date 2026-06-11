#!/bin/bash

# Auto-detect volume control tool and execute command
# Usage: volume_control.sh [up|down|mute|mic-mute] [step]

ACTION=$1
STEP=${2:-5%}

update_i3status() {
    killall -SIGUSR1 i3status 2>/dev/null
}

# Helpers to get volume and mute status
get_volume() {
    local tool=$1
    case $tool in
        pactl)  pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -Po '[0-9]+(?=%)' | head -n 1 ;;
        amixer) amixer sget Master 2>/dev/null | grep -Po '\[[0-9]+%\]' | head -n 1 | tr -d '[]%' ;;
    esac
}

get_mute() {
    local tool=$1
    case $tool in
        pactl)  pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -i "yes" ;;
        amixer) amixer sget Master 2>/dev/null | grep -Po '\[off\]' | head -n 1 ;;
    esac
}

send_notification() {
    local tool=$1
    if command -v notify-send >/dev/null 2>&1; then
        local mute=$(get_mute $tool)
        local vol=$(get_volume $tool)

        if [ -n "$mute" ]; then
            notify-send -h string:x-canonical-private-synchronous:volume \
                        -h int:value:0 \
                        -t 1000 "Volume" "Muted" -i audio-volume-muted
        elif [ -n "$vol" ]; then
            local icon="audio-volume-high"
            if [ "$vol" -lt 33 ]; then icon="audio-volume-low"
            elif [ "$vol" -lt 66 ]; then icon="audio-volume-medium"
            fi
            
            notify-send -h string:x-canonical-private-synchronous:volume \
                        -h int:value:"$vol" \
                        -t 1000 "Volume" "${vol}%" -i "$icon"
        fi
    fi
}

# Try tools in order of preference
for tool in pactl amixer; do
    if command -v $tool >/dev/null 2>&1; then
        # Check if the tool actually works
        initial_vol=$(get_volume $tool)
        if [ -n "$initial_vol" ]; then
            case $tool in
                pactl)
                    case $ACTION in
                        up)       pactl set-sink-volume @DEFAULT_SINK@ +"$STEP" && update_i3status ;;
                        down)     pactl set-sink-volume @DEFAULT_SINK@ -"$STEP" && update_i3status ;;
                        mute)     pactl set-sink-mute @DEFAULT_SINK@ toggle     && update_i3status ;;
                        mic-mute) pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
                    esac
                    ;;
                amixer)
                    case $ACTION in
                        up)       amixer -q sset Master "$STEP"+ unmute && update_i3status ;;
                        down)     amixer -q sset Master "$STEP"- unmute && update_i3status ;;
                        mute)     amixer -q sset Master toggle          && update_i3status ;;
                        mic-mute) amixer -q sset Capture toggle ;;
                    esac
                    ;;
            esac
            
            [ "$ACTION" != "mic-mute" ] && send_notification $tool
            exit 0
        fi
    fi
done

echo "No working volume control tool found (pactl, amixer)" >&2
exit 1
