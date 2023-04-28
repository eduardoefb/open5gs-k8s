#!/bin/bash
while ! curl ${PREFIX}-mongodb:27017; do 
    echo "`date` Waiting for mongodb..."
    sleep 5
done