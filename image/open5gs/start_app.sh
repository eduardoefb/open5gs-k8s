#!/bin/bash

# Get IP address:
ipaddr=`ip addr show dev eth0 | grep -oP '(?<=inet\s)(.*)(?=\/)'`

# Replace the ip address in the config file:
sed "s|0.0.0.0|${ipaddr}|g" /opt/open5gs/config/${NETYPE}.yaml > /etc/open5gs/${NETYPE}.yaml

# Start application
if [ -z "${DEBUG}" ]; then
    /usr/bin/open5gs-${NETYPE}d -c /etc/open5gs/${NETYPE}.yaml
else
    /usr/bin/open5gs-${NETYPE}d -c /etc/open5gs/${NETYPE}.yaml -d
fi