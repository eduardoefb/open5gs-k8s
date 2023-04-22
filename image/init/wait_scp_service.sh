#!/bin/bash
while ! host ${PREFIX}-scp; do 
    echo "`date` Waiting for scp service..."
    sleep 5
done