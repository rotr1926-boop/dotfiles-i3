#!/bin/bash
SINK=$(pactl list sinks short | grep -v easyeffects | head -1 | awk '{print $2}')
VOL=$(pactl get-sink-volume "$SINK" | head -1 | awk '{print $5}')
MUTE=$(pactl get-sink-mute "$SINK" | awk '{print $2}')
if [ "$MUTE" = "yes" ]; then
    echo "Vol: MUTED"
else
    echo "Vol: $VOL"
fi
