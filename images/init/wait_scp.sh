#!/bin/bash
while ! curl ${PREFIX}-scp:8080; do 
    echo "`date` Waiting for scp..."
    sleep 5
done