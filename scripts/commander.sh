#!/bin/bash

commander() {
	while read ip_address; do
		ssh root@$ip_address "/root/mass-commander/scripts/client-side.sh" &
	done</root/mass-commander/runtime-files/ip-address-pool
}

ip_addresses_finder() {
	perm_ip_addr_with_sub_mask=$(cat /root/mass-commander/permanent-files/permanent-ip-address-with-subnet-mask)
	arp-scan "$perm_ip_addr_with_sub_mask" > /root/mass-commander/runtime-files/arp-scan-output
	no_of_lines=$(wc -l /root/mass-commander/runtime-files/arp-scan-output | awk -F' ' '{print $1}')
	
	line_just_below_result=$(($no_of_lines - 2))
	cat /root/mass-commander/runtime-files/arp-scan-output | sed "${line_just_below_result},${no_of_lines}d" | sed '1,2d' > /root/mass-commander/runtime-files/arp-scan-unwanted-lines-deleted
	cat /root/mass-commander/runtime-files/arp-scan-unwanted-lines-deleted | awk -F' ' '{print $1}' > /root/mass-commander/runtime-files/ip-address-pool 
}

files_tarrer() {
	ls /root/mass-commander/runtime-files/file-tarring-area > /root/mass-commander/runtime-files/filenames-to-tar-without-path
	tar -czf /root/mass-commander/runtime-files/files-from-server.tar.gz -C /root/mass-commander/runtime-files/file-tarring-area $(cat /root/mass-commander/runtime-files/filenames-to-tar-without-path)
}

files_to_tar_loc_copier() {
	if [ -d /root/mass-commander/runtime-files/file-tarring-area ]; then
		rm -r /root/mass-commander/runtime-files/file-tarring-area
		mkdir /root/mass-commander/runtime-files/file-tarring-area
	else
		mkdir /root/mass-commander/runtime-files/file-tarring-area
	fi

	while read file_location; do 
		cp $file_location /root/mass-commander/runtime-files/file-tarring-area
	done</root/mass-commander/runtime-files/files-to-tar
}

echo '/root/mass-commander/runtime-files/files-from-server/app-opener.sh' >> /root/mass-commander/runtime-files/commands-to-run

echo '/root/mass-commander/runtime-files/commands-to-run' >> /root/mass-commander/runtime-files/files-to-tar
echo '/root/mass-commander/scripts/app-opener.sh' >> /root/mass-commander/runtime-files/files-to-tar
echo '/root/mass-commander/permanent-files/app-to-open' >> /root/mass-commander/runtime-files/files-to-tar

files_to_tar_loc_copier
files_tarrer

cp /root/mass-commander/runtime-files/files-from-server.tar.gz /srv/sftp/data

ip_addresses_finder
commander
