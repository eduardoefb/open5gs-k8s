#!/bin/bash

if [ `netstat -anS | grep ESTABLISHED | wc -l` -gt 0 ]; then
    exit 0
fi

exit 1