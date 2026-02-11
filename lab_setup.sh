#!/bin/bash

working_dir="/root/server_setup"
netcat_file_loc="$working_dir/netcat_file.sh"

echo 'enter ip of server machine'
read server_ip

echo 'enter port to use'
read port_no

#----------------------------------------------------------------------
# check for nc file existence
#----------------------------------------------------------------------

[ -f $netcat_file_loc ] || echo 'couldnt find the file for netcat' ; exit 1

echo 'starting netcat'
cat $netcat_file_loc | nc -u -s $server_ip -b 255.255.255.255 $port_no
