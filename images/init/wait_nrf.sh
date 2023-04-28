#!/bin/bash
while ! curl ${PREFIX}-nrf:8080; do 
    echo "`date` Waiting for nrf..."
    sleep 5
done