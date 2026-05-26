#!/bin/bash

# Auto-detect brightness control tool and execute command
# Usage: backlight_control.sh [up|down] [step]

ACTION=$1
STEP=${2:-5}

# Helper to get current brightness
get_brightness() {
    local tool=$1
    case $tool in
        xbacklight)    xbacklight -get 2>/dev/null | cut -d. -f1 ;;
        brightnessctl) brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' ;;
        light)         light -G 2>/dev/null | cut -d. -f1 ;;
    esac
}

send_notification() {
    local val=$1
    if [ -n "$val" ] && command -v notify-send >/dev/null 2>&1; then
        notify-send -h string:x-canonical-private-synchronous:brightness -t 1000 "Brightness" "${val}%"
    fi
}

# Try tools in order of preference
for tool in xbacklight brightnessctl light; do
    if command -v $tool >/dev/null 2>&1; then
        # Check if the tool actually works
        initial_val=$(get_brightness $tool)
        if [ -n "$initial_val" ]; then
            case $tool in
                xbacklight)
                    case $ACTION in
                        up)   xbacklight -inc "$STEP" ;;
                        down) xbacklight -dec "$STEP" ;;
                    esac
                    ;;
                brightnessctl)
                    case $ACTION in
                        up)   brightnessctl set "${STEP}%+" ;;
                        down) brightnessctl set "${STEP}%-" ;;
                    esac
                    ;;
                light)
                    case $ACTION in
                        up)   light -A "$STEP" ;;
                        down) light -U "$STEP" ;;
                    esac
                    ;;
            esac
            
            # Send notification using the active tool's new value
            new_val=$(get_brightness $tool)
            send_notification "$new_val"
            exit 0
        fi
    fi
done

echo "No working brightness control tool found (xbacklight, brightnessctl, light)" >&2
exit 1
