#!/bin/bash

#shouldn't use here due to fail in opening apps in some users
#set -e

commander() {
	while read ip_address; do
		ssh root@$ip_address "client-side.sh" &
	done < /root/mass-commander/runtime-files/ip-address-pool
}

ip_addresses_finder() {
	perm_ip_addr_with_sub_mask=$(cat ./settings/permanent-ip-address-with-subnet-mask) arp-scan "$perm_ip_addr_with_sub_mask" > ./runtime-files/arp-scan-output
	no_of_lines=$(wc -l ./runtime-files/arp-scan-output | awk -F' ' '{print $1}')
	
	line_just_below_result=$(($no_of_lines - 2))
	cat ./runtime-files/arp-scan-output | sed "${line_just_below_result},${no_of_lines}d" | sed '1,2d' > ./runtime-files/arp-scan-unwanted-lines-deleted
	cat ./runtime-files/arp-scan-unwanted-lines-deleted | awk -F' ' '{print $1}' > ./runtime-files/ip-address-pool 
}

echo './files-from-server/app-opener.sh' >> ./runtime-files/commands-to-run
echo './runtime-files/commands-to-run' >> files-to-tar

cd /root/mass-commander/runtime-files/
tar -czf files-from-server.tar.gz $(cat /root/mass-commander/runtime-files/files-to-tar)
cp /root/mass-commander/runtime-files/files-from-server.tar.gz /srv/sftp/data

ip_addresses_finder
commander
