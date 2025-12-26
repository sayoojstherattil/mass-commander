#!/bin/bash -e

commander() {
	while read ip_address; do
		ssh root@$ip_address "source $runtime_files_dir_for_clients/commands-for-clients-to-run" &
	done<$runtime_files_dir/ip-address-pool
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
