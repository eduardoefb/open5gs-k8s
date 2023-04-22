#!/bin/bash

# Get IP address:
ipaddr=`ip addr show dev eth0 | grep -oP '(?<=inet\s)(.*)(?=\/)'`
gnodeb_ip=`kubectl get pod -l  app=open5gs-gnodeb -o wide | grep  -oP '\d+\.\d+\.\d+\.\d+' | tail -1`

# Replace the ip address in the config file:
sed "s|#GNODEB_IP#|${gnodeb_ip}|g" /opt/open5gs/config/subscriber.yaml  > /etc/subscriber.yaml


# Start ue
cd /opt/UERANSIM
build/nr-ue -c /etc/subscriber.yaml