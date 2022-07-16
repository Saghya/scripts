#!/bin/bash

VOLUME=$(pamixer --get-volume)
[ "$VOLUME" -gt 100 ] && pactl set-sink-volume 0 100%

function send_notification() {
    dash=$(seq -s "─" 0 $((VOLUME / 5)) | sed 's/[0-9]//g')
    space=$(seq -s "." 0 $(( 20 - $((VOLUME / 5)))) | sed 's/[0-9]//g')
    bar=$dash$space
    dunstify -r 5555 -t 1000 "$1  $bar"
}

if pamixer --get-volume-human | grep -q "muted"; then
    dunstify -r 5555 -t 1000 "....................  ﱝ"
elif [ "$VOLUME" = 0 ]; then
    send_notification "婢"
elif [ "$VOLUME" -lt 33 ]; then
    send_notification "奄"
elif [ "$VOLUME" -lt 66 ]; then
    send_notification "奔"
else
    send_notification "墳"
fi

