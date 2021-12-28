#!/bin/bash

VOLUME=$(pactl list sinks | grep '^[[:space:]]Volume:' | \
    head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
sink="$(pactl info | awk '$1 == "Default" && $2 == "Sink:" {print $3}')"
[ -n "$sink" ] || exit
MUTED=$(pactl list sinks | awk -v sink="$sink" '{ if ($1 == "Mute:" && $2 == "yes") {print $2} }')

function send_notification() {
    dash=$(seq -s "─" 0 $((VOLUME / 5)) | sed 's/[0-9]//g')
    space=$(seq -s "." 0 $(( 20 - $((VOLUME / 5)))) | sed 's/[0-9]//g')
    bar=$dash$space
    dunstify -r 5555 "$1  $bar"
}

if [ "$MUTED" = "yes" ]
then
    dunstify -r 5555 "....................  ﱝ"
elif [ "$VOLUME" = 0 ]
then
    send_notification "婢"
elif [ "$VOLUME" -lt 33 ]
then
    send_notification "奄"
elif [ "$VOLUME" -lt 66 ]
then
    send_notification "奔"
else
    send_notification "墳"
fi

