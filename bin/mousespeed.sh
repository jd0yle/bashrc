#!/usr/bin/env bash
speed=$1

if [[ "$speed" = "" ]]; then
   echo "./mousespeed.sh <speed>"
   echo "[ERROR] Speed not specified"
   exit -1
fi

echo "Setting Razer mousespeed to $speed"
ids=$(xinput list | ack 'Razer Mamba Tournament Edition\s+id=(\d+).*pointer' --output='$1')
for id in $ids; do
    prop=$(xinput list-props $id | ack 'Device Accel Constant Deceleration \((\d+)\)' --output='$1')
    xinput set-prop $id $prop $speed
done
