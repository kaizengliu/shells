#!/bin/bash

# kill the existed process of sslocal
sudo lsof -i tcp:1080 | grep -e '^sslocal' | awk '{print $2}' | uniq | xargs kill -9 

country=$1
default_country="sg01"

if [ ! ${country} ]; then
    country=${default_country}
fi

sslocal -s ${country}.ssss.io -p 25206 -k  678122  -m rc4-md5 -q
