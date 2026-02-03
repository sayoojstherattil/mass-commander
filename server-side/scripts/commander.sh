#!/bin/bash

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
		ssh -o StrictHostKeyChecking=no root@$ip_address "/root/mass-commander/scripts/client-side.sh > client-side-output">$runtime_files_dir/ssh-output-of-${ip_address} 2>&1 &
	done<$runtime_files_dir/ip-address-pool
}

ip_addresses_finder() {
	perm_ip_addr_with_sub_mask=$(cat $permanent_files_dir/permanent-ip-address-with-subnet-mask)

	echo
	echo "fetching ip addresses..."
	echo
	arp-scan "$perm_ip_addr_with_sub_mask" > $runtime_files_dir/arp-scan-output 2>/dev/null

	last_line_number=$(wc -l $runtime_files_dir/arp-scan-output | awk -F' ' '{print $1}')
	line_just_below_result=$(($last_line_number - 2))

	cat $runtime_files_dir/arp-scan-output | sed "${line_just_below_result},${last_line_number}d" | sed '1,2d' > $runtime_files_dir/arp-scan-unwanted-lines-deleted
	cat $runtime_files_dir/arp-scan-unwanted-lines-deleted | awk -F' ' '{print $1}' > $runtime_files_dir/ip-address-pool 
}

commands-for-clients-to-run.sh "echo"
commands-for-clients-to-run.sh "echo DONE!"

cp $runtime_files_dir/commands-to-run-of-client /srv/sftpuser/data

ip_addresses_finder

eval $(ssh-agent)
ssh-add ${clients_accesing_private_key}

commander
