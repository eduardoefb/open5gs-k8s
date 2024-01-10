#!/bin/bash

# Get IP address:
ipaddr=`ip addr show dev eth0 | grep -oP '(?<=inet\s)(.*)(?=\/)'`

# Replace the ip address in the config file:
sed "s|0.0.0.0|${ipaddr}|g" /opt/open5gs/config/${NETYPE}.yaml > /etc/open5gs/${NETYPE}.yaml

# Start application
if [ "${NETYPE}" == "upf" ]; then 
    if [ -z "${DEBUG}" ]; then
        /usr/bin/open5gs-${NETYPE}d -c /etc/open5gs/${NETYPE}.yaml > /var/log/upf.log &
    else
        /usr/bin/open5gs-${NETYPE}d -c /etc/open5gs/${NETYPE}.yaml -d  > /var/log/upf.log &
    fi
    sleep 10
    addr=`cat /etc/open5gs/upf.yaml  | grep -A1 subnet: | grep "subnet:" | awk '{print $NF}'`
    ip addr add ${addr} dev ogstun
    ip link set ogstun up
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    tail -f /var/log/upf.log 
else
    if [ -z "${DEBUG}" ]; then
        /usr/bin/open5gs-${NETYPE}d -c /etc/open5gs/${NETYPE}.yaml
    else
        /usr/bin/open5gs-${NETYPE}d -c /etc/open5gs/${NETYPE}.yaml -d
    fi
fi