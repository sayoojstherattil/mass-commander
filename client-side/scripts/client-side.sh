#!/bin/bash

export mass_commander_base_dir="/root/mass-commander"
export runtime_files_dir="$mass_commander_base_dir/runtime-files"
export permanent_files_dir="$mass_commander_base_dir/permanent-files"
export sftp_username="sftpuser"
perm_ip_addr_with_sub_mask=$(cat $permanent_files_dir/permanent-ip-address-with-subnet-mask)
export sftp_server_ip=$(echo $perm_ip_addr_with_sub_mask | awk -F'/' '{print $1}')
export sftp_directory="/data"

command_output_file_ensurer() {
	if [ -f $runtime_files_dir/command-output ]; then
		rm $runtime_files_dir/command-output
		touch $runtime_files_dir/command-output
	else
		touch $runtime_files_dir/command-output
	fi
}

directory_ensurer() {
	directory_name="$1"

	if [ -d $directory_name ]; then
		rm -r $directory_name
		mkdir $directory_name
	else
		mkdir $directory_name
	fi
}


directory_ensurer "$runtime_files_dir"

#commands-to-run file fetcher
cd $runtime_files_dir
sftp $sftp_username@$sftp_server_ip <<< $"get $sftp_directory/commands-to-run-of-client"
cd -

command_output_file_ensurer

source $runtime_files_dir/commands-to-run-of-client>/home/command-output 2>&1
