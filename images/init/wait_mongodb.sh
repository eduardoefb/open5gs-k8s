#!/bin/bash
while ! curl ${PREFIX}-mongodb:27017; do 
    echo "`date` Waiting for mongodb..."
    sleep 5
done
timer=`shuf -i 1-30 -n 1`
echo "`date` MongoDB is ready. Waiting for ${timer} seconds to ensure its stability..."
sleep ${timer}