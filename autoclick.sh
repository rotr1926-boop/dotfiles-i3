#!/bin/bash

PIDFILE="/tmp/autoclick.pid"

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")"
    rm "$PIDFILE"
    exit
fi

(
# 🔹 CLICK INIZIALE (UNA SOLA VOLTA)
xdotool mousemove 1580 438
sleep 1
xdotool click 1
sleep 1

# 🔁 LOOP PRINCIPALE
while true; do
    # Punto 1
    xdotool mousemove 148 1204
    sleep 0.1
    xdotool click 1
    sleep 0.15

    # Punto 2
    xdotool mousemove 284 1091
    sleep 0.1
    xdotool click 1
    sleep 0.05
    xdotool click 1
    sleep 0.3
done
) &

echo $! > "$PIDFILE"


