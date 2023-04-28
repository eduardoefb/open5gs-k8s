#!/bin/bash

/usr/bin/mongod --unixSocketPrefix=/run/mongodb --config /etc/mongodb.conf&
sleep 10
#if ! mongo <<< 'show dbs' | grep open5gs ; then 
  cd /opt/ && bash post_install_npm
#fi
sleep 10
cd /usr/lib/node_modules/open5gs
NODE_ENV=production /usr/bin/node server/index.js&
sleep 1
tail -f /var/log/mongodb/mongodb.log