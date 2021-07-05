#!/bin/bash

VOLUME=$(pamixer --get-volume)

if [ $(pamixer --get-volume-human) == "muted" ] 
then 
	echo ""
elif [ "$VOLUME" == 0 ]
then
	echo ""
elif [ "$VOLUME" -lt 50 ]
then
	echo " $VOLUME%"
else
	echo " $VOLUME%"
fi

