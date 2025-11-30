#!/bin/bash

#shouldn't use here due to fail in opening apps in some users
#set -e

ip_addresses_finder() {
	perm_ip_addr_with_sub_mask=$(cat ./settings/permanent-ip-address-with-subnet-mask)
	arp-scan "$perm_ip_addr_with_sub_mask" > ./runtime-files/arp-scan-output
	no_of_lines=$(wc -l ./runtime-files/arp-scan-output | awk -F' ' '{print $1}')
	
	line_just_below_result=$(($no_of_lines - 2))
	cat ./runtime-files/arp-scan-output | sed "${line_just_below_result},${no_of_lines}d" | sed '1,2d' > ./runtime-files/arp-scan-unwanted-lines-deleted
	cat ./runtime-files/arp-scan-unwanted-lines-deleted | awk -F' ' '{print $1}' > ./runtime-files/ip-address-pool 
}

command_for_opening_app
ip_addresses_finder
files_in_sftp_dir_placer

user_login_type=$(cat ./runtime-files/user_login_type)
actual_command=$(cat ./runtime-files/command-from-script)

