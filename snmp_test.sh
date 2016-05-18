#!/bin/bash

function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))
}

rnd=$(rand 1 1000)

community="private"
ip_device="10.217.13.231"
tftp_server="10.73.17.248"

snmpset -c $community -v 2c $ip_device 1.3.6.1.4.1.9.9.96.1.1.1.1.2.$rnd i 1
snmpset -c $community -v 2c $ip_device 1.3.6.1.4.1.9.9.96.1.1.1.1.3.$rnd i 4
snmpset -c $community -v 2c $ip_device 1.3.6.1.4.1.9.9.96.1.1.1.1.4.$rnd i 1
snmpset -c $community -v 2c $ip_device 1.3.6.1.4.1.9.9.96.1.1.1.1.5.$rnd a $tftp_server
snmpset -c $community -v 2c $ip_device 1.3.6.1.4.1.9.9.96.1.1.1.1.6.$rnd s x_router.conf
snmpset -c $community -v 2c $ip_device 1.3.6.1.4.1.9.9.96.1.1.1.1.14.$rnd i 1


snmptable -v2c -c private $ip_device  CISCO-CONFIG-COPY-MIB::ccCopyTable
