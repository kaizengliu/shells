#!/bin/bash

function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))
}

function check_status() {
    status=$1
    error_msg=$2

    
    if [ $status -ne 0 ]; then
	echo -e "\033[1;31m"${error_msg}"\033[0m"
	exit $status
    fi
}


community="private"
tftp_server="10.73.17.248"
device_ip=""
config_file=""
rnd=$(rand 1 1000)

function usage() {
    echo -e "\033[1;32mbackup device configuration to tftp server(${tftp_server}) through snmp\033[0m"
    echo ""
    echo "usage:"
    echo "snmp_config_bak "
    echo "-h --help"
    echo -e "-i ip_addr,\033[1;31mrequired\033[0m"
    echo -e "-c community, \033[1;31moptional\033[0m"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=$1

    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        -i | --ip)
	    shift
            device_ip=$1
	    config_file=$device_ip.config
            ;;
        -c | --community)
	    shift
            community=$1
            ;;
        *) ;;
    esac
    
    shift
done

if [ -z $device_ip ]; then
    usage
    exit 0
fi

if [ -z $community ]; then
    usage
    exit 0
fi

snmpset -c "$community" -v 2c $device_ip 1.3.6.1.4.1.9.9.96.1.1.1.1.2.$rnd i 1 >/dev/null
check_status $? "set CISCO-CONFIG-COPY-MIB::ccCopyProtocol tftp fail" 

snmpset -c "$community" -v 2c $device_ip 1.3.6.1.4.1.9.9.96.1.1.1.1.3.$rnd i 4 >/dev/null
check_status $? "set CISCO-CONFIG-COPY-MIB::ccCopySourceFileType runningConfig fail"

snmpset -c "$community" -v 2c $device_ip 1.3.6.1.4.1.9.9.96.1.1.1.1.4.$rnd i 1 >/dev/null
check_status $? "set CISCO-CONFIG-COPY-MIB::ccCopyDestFileType networkFile fail"

snmpset -c "$community" -v 2c $device_ip 1.3.6.1.4.1.9.9.96.1.1.1.1.5.$rnd a $tftp_server >/dev/null
check_status $? "set CISCO-CONFIG-COPY-MIB::ccCopyServerAddress "$tftp_server" fail"

snmpset -c "$community" -v 2c $device_ip 1.3.6.1.4.1.9.9.96.1.1.1.1.6.$rnd s $config_file >/dev/null
check_status $? "set CISCO-CONFIG-COPY-MIB::ccCopyFileName "$config_file" fail"

snmpset -c "$community" -v 2c $device_ip 1.3.6.1.4.1.9.9.96.1.1.1.1.14.$rnd i 1 >/dev/null
check_status $? "set CISCO-CONFIG-COPY-MIB::ccCopyEntryRowStatus status fail"

