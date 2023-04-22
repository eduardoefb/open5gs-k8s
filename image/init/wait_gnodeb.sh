#!/bin/bash

# Get IP address:
ipaddr=`ip addr show dev eth0 | grep -oP '(?<=inet\s)(.*)(?=\/)'`

while :; do
   gnodeb_ip=`kubectl get pod -l  app=${PREFIX}-gnodeb -o wide | grep  -P '\s+(\d+)/\1\s+' | grep  -oP '\d+\.\d+\.\d+\.\d+' | tail -1`
   
   if [ ! -z "${gnodeb_ip}" ]; then
      echo "`date` AMF is ready!"
      sleep 5
      break
   fi
   sleep 5
   echo "`date` Waiting for amf..."
done


