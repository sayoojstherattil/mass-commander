#!/bin/bash

termial_spawn_parameter="$1"

commander() {
	if [ "$termial_spawn_parameter" = "terminal_spawn on" ]; then
		while read ip_address; do
			ssh root@$ip_address "/root/mass-commander/client-side.sh 'termial_spawn on'" &
		done<$runtime_files_dir/ip-address-pool
	elif [ "$termial_spawn_parameter" = "terminal_spawn off" ]; then
		while read ip_address; do
			ssh root@$ip_address "/root/mass-commander/client-side.sh 'termial_spawn off'" &
		done<$runtime_files_dir/ip-address-pool
	fi
}

ip_addresses_finder() {
	perm_ip_addr_with_sub_mask=$(cat $settings_dir/permanent-ip-address-with-subnet-mask)

	arp-scan "$perm_ip_addr_with_sub_mask" > $runtime_files_dir/arp-scan-output

	last_line_number=$(wc -l $runtime_files_dir/arp-scan-output | awk -F' ' '{print $1}')
	line_just_below_result=$(($last_line_number - 2))

	cat $runtime_files_dir/arp-scan-output | sed "${line_just_below_result},${last_line_number}d" | sed '1,2d' > $runtime_files_dir/arp-scan-unwanted-lines-deleted
	cat $runtime_files_dir/arp-scan-unwanted-lines-deleted | awk -F' ' '{print $1}' > $runtime_files_dir/ip-address-pool 
}

ip_addresses_finder
commander
