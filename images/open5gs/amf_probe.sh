#!/bin/bash

if netstat -anS | grep LISTEN; then 
    exit 0
else
    exit 1
fi