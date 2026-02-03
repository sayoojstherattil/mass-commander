#!/bin/bash

export mass_commander_base_dir="/root/mass-commander"
export runtime_files_dir="$mass_commander_base_dir/runtime-files"
export permanent_files_dir="$mass_commander_base_dir/permanent-files"
export sftp_username="sftpuser"
perm_ip_addr_with_sub_mask=$(cat $permanent_files_dir/permanent-ip-address-with-subnet-mask)
export sftp_server_ip=$(echo $perm_ip_addr_with_sub_mask | awk -F'/' '{print $1}')
export sftp_directory="/data"
export sftp_accessing_private_key_name="id_rsa"

one_doing_remover() {
	while read username; do
		if [ -f /home/$username/one-doing ]; then
			rm /home/$username/one-doing
		fi
	done<$runtime_files_dir/running-usernames
}

running_users_finder() {
	w > $runtime_files_dir/w-output
	no_of_lines_in_w_output=$(wc -l $runtime_files_dir/w-output | awk -F' ' '{print $1}')
	sed -n 3,${no_of_lines_in_w_output}p $runtime_files_dir/w-output > $runtime_files_dir/running-users-details
	sed -n 3,3p $runtime_files_dir/w-output | awk -F' ' '{print $1}' > $runtime_files_dir/running-usernames
}


command_output_file_ensurer() {
	if [ -f /home/command-output ]; then
		rm /home/command-output
		touch /home/command-output
	else
		touch /home/command-output
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
command_output_file_ensurer

eval $(ssh-agent)
ssh-add ~/.ssh/${sftp_accessing_private_key_name}

#commands-to-run file fetcher
cd $runtime_files_dir
sftp $sftp_username@$sftp_server_ip <<< $"get $sftp_directory/commands-to-run-of-client"
cd -

running_users_finder
one_doing_remover

source $runtime_files_dir/commands-to-run-of-client>/home/command-output 2>&1
