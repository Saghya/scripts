#!/bin/bash

BAT=$(< /sys/class/power_supply/BAT0/capacity)

if [ $(< /sys/class/power_supply/AC/online) == 1 ]
then
	echo " $BAT%"
else
	if  [ "$BAT" -gt 0 ] && [ "$BAT" -lt 13 ]
	then
		echo " $BAT%"
	elif [ "$BAT" -gt 12 ] && [ "$BAT" -lt 38 ]
	then
		echo " $BAT%"
	elif [ "$BAT" -gt 37 ] && [ "$BAT" -lt 63 ]
	then
		echo " $BAT%"
	elif [ "$BAT" -gt 62 ] && [ "$BAT" -lt 88 ]
	then
		echo " $BAT%"
	else
		echo " $BAT%"
	fi
fi

