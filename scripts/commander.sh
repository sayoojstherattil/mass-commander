#!/bin/bash

commander() {
	while read ip_address; do
		ssh root@$ip_address "client-side.sh" &
	done<$runtime_files_dir/ip-address-pool
}

ip_addresses_finder() {
	perm_ip_addr_with_sub_mask=$(cat /root/mass-commander/permanent-files/permanent-ip-address-with-subnet-mask)
	arp-scan "$perm_ip_addr_with_sub_mask" > $runtime_files_dir/arp-scan-output
	no_of_lines=$(wc -l $runtime_files_dir/arp-scan-output | awk -F' ' '{print $1}')
	
	line_just_below_result=$(($no_of_lines - 2))
	cat $runtime_files_dir/arp-scan-output | sed "${line_just_below_result},${no_of_lines}d" | sed '1,2d' > $runtime_files_dir/arp-scan-unwanted-lines-deleted
	cat $runtime_files_dir/arp-scan-unwanted-lines-deleted | awk -F' ' '{print $1}' > $runtime_files_dir/ip-address-pool 
}

files_tarrer() {
	ls $runtime_files_dir/files-tarring-area >> $runtime_files_dir/files-to-tar
	tar -czf $runtime_files_dir/files-from-server.tar.gz -C $runtime_files_dir/files-tarring-area $(cat $runtime_files_dir/files-to-tar)
}

always_required_files_to_tarring_area_copier() {
	cp $runtime_files_dir/commands-to-run $runtime_files_dir/files-to-tar
	cp app-opener.sh $runtime_files_dir/files-to-tar
	cp /root/mass-commander/permanent-files/app-to-open $runtime_files_dir/files-to-tar
}

files_tarring_area_dir_ensurer() {
	if [ -d $runtime_files_dir/files-tarring-area ]; then
		rm -r $runtime_files_dir/files-tarring-area
		mkdir $runtime_files_dir/files-tarring-area
	else
		mkdir $runtime_files_dir/files-tarring-area
	fi
}

#is always done after successful completion of job
echo '$runtime_files_dir/files-from-server/app-opener.sh' >> $runtime_files_dir/commands-to-run

files_tarring_area_dir_ensurer
always_required_files_to_tarring_area_copier
files_tarrer

cp $runtime_files_dir/files-from-server.tar.gz /srv/sftp/data

ip_addresses_finder
commander
