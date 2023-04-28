#!/bin/bash

imsi=`cat /opt/open5gs/subscriber.yaml  | grep  -oP '(?<=imsi-)(\d+)'`
key=`cat /opt/open5gs/subscriber.yaml | grep -oP "(?<=key:\s')(.*)(?=')"`
op=`cat /opt/open5gs/subscriber.yaml | grep -oP "(?<=op:\s')(.*)(?=')"`
if cd /home/open5gs && bash -x open5gs/misc/db/open5gs-dbctl --db_uri=mongodb://${PREFIX}-mongodb/open5gs add ${imsi} ${key} ${op}; then
    exit 0
else
    exit 1
fi
