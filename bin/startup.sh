#!/usr/bin/env bash

function mousespeed {
    speed=$1
    ids=$(xinput list | ack 'Razer Mamba Tournament Edition\s+id=(\d+).*pointer' --output='$1')
    for id in $ids; do
	prop=$(xinput list-props $id | ack 'Device Accel Constant Deceleration \((\d+)\)' --output='$1')
	xinput set-prop $id $prop $speed
    done
}

mousespeed 1.5
