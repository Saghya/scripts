#!/bin/bash

WIFI=$(< /sys/class/net/wlp0s20f3/operstate)
UTP=$(< /sys/class/net/enp4s0/operstate)

if [[ "$UTP" == "up" ]]
then
	echo " [] "
elif [[ "$WIFI" == "up" ]]
then
	echo " [] "
else
	echo " "
fi

