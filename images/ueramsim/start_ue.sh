#!/bin/bash

# Get IP address:
ipaddr=`ip addr show dev eth0 | grep -oP '(?<=inet\s)(.*)(?=\/)'`
gnodeb_ip=`kubectl get pod -l  app=open5gs-gnodeb -o wide | grep  -oP '\d+\.\d+\.\d+\.\d+' | tail -1`
k8s=`host kubernetes  | awk '{print $NF}'`
gw=`ip route | grep default | awk '{print $3}'`

# Replace the ip address in the config file:
#sed "s|#GNODEB_IP#|${gnodeb_ip}|g" /opt/open5gs/config/subscriber.yaml  > /etc/subscriber.yaml
python3 /opt/subscriber_config.py ${gnodeb_ip}

# Start ue
cd /opt/UERANSIM
build/nr-ue -c /etc/subscriber.yaml > /tmp/ue.log &
sleep 5
ip route add ${gnodeb_ip} via ${gw}
ip route add ${k8s} via ${gw}
ip route del default
ip route add default via ${gw} metric 10
ip route add default dev uesimtun0 metric 0
tail -f /tmp/ue.log
