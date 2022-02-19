#!/bin/sh

set -e

#Start-up socat to bind the remote serial to IP relay to a virtual port on /dev/hottub
socat pty,link=/dev/hottub,b115200,raw,echo=0 tcp4:${BRIDGE_IP}:${BRIDGE_PORT},forever,interval=10,fork &

#Launch the bwa_mqtt_bridge 
/usr/local/bundle/bin/bwa_mqtt_bridge ${MQTT_URI} /dev/hottub