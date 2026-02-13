#!/bin/bash

working_dir="/root/server_setup"
netcat_file_loc="$working_dir/netcat_file.sh"


#----------------------------------------------------------------------
# check for nc file existence
#----------------------------------------------------------------------

[ -f $netcat_file_loc ] || echo 'couldnt find the file for netcat' ; exit 1


echo 'enter ip of server machine'
read server_ip

echo 'enter port to use'
read port_no

#----------------------------------------------------------------------
# tell admin to enter the netcat commands on client machines
#----------------------------------------------------------------------

echo "enter this command on all client machines and respond to sudo password entry when prompted:"
echo "nc -ulp $port_no | bash"

#----------------------------------------------------------------------
# start netcat after admin confirm he/she has entered the command in client machines
#----------------------------------------------------------------------

echo -n 'after entering the command on client machines, press enter'
read

echo -e "\nstarting netcat"
cat $netcat_file_loc | nc -u -s $server_ip -b 255.255.255.255 $port_no
