#!/bin/bash

ip_addresses_finder() {
	perm_ip_addr_with_sub_mask=$(cat $permanent_files_dir/permanent_ip_address_with_subnet_mask)

	echo
	echo "fetching ip addresses..."
	echo
	arp_scan "$perm_ip_addr_with_sub_mask" > $runtime_files_dir/arp_scan_output 2>/dev/null

	last_line_number=$(wc -l $runtime_files_dir/arp_scan_output | awk -F' ' '{print $1}')
	line_just_below_result=$(($last_line_number - 2))

	cat $runtime_files_dir/arp_scan_output | sed "${line_just_below_result},${last_line_number}d" | sed '1,2d' > $runtime_files_dir/arp_scan_unwanted_lines_deleted
	cat $runtime_files_dir/arp_scan_unwanted_lines_deleted | awk -F' ' '{print $1}' > $runtime_files_dir/ip_address_pool 
}

sftp_directory_files_permission_changer() {
	ls $sftp_directory > $runtime_files_dir/files_in_sftp

	while read filename; do
		chmod 644 ${sftp_directory}/${filename}
	done<$runtime_files_dir/files_in_sftp
}

commander() {
	echo -n "starting in 3.."
	sleep 1
	echo -n "2.."
	sleep 1
	echo -n "1.."
	sleep 1

	echo
	echo begun

	while read ip_address; do
		ssh -o StrictHostKeyChecking=no root@$ip_address "/root/mass_commander/scripts/client_side.sh > client_side_output">$runtime_files_dir/ssh_output_of_${ip_address} 2>&1 &
	done<$runtime_files_dir/ip_address_pool
}


commands_for_clients_to_run.sh "echo"
commands_for_clients_to_run.sh "echo DONE!"

cp $runtime_files_dir/commands_to_run_of_client /srv/sftpuser/data

ip_addresses_finder
sftp_directory_files_permission_changer
commander
