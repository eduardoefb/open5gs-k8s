#!/bin/bash

# Get IP address:
ipaddr=`ip addr show dev eth0 | grep -oP '(?<=inet\s)(.*)(?=\/)'`
amf_ip=`kubectl get pod -l  app=${PREFIX}-amf -o wide | grep  -oP '\d+\.\d+\.\d+\.\d+' | tail -1`
echo ${amf_ip} > /tmp/amf_ip

# Replace the ip address in the config file:
sed "s|0\.0\.0\.0|${ipaddr}|g" /opt/open5gs/config/${NETYPE}.yaml > /etc/${NETYPE}.yaml


# Workaround due to kuberntes sctp support
sed -i "s|- address: ${PREFIX}-amf|- address: ${amf_ip}|g" /etc/${NETYPE}.yaml

# Start gnodeb
cd /opt/UERANSIM
sleep 5
build/nr-gnb -c /etc/${NETYPE}.yaml

