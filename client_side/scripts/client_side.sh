#!/bin/bash

export mass_commander_base_dir="/root/mass_commander"
export runtime_files_dir="$mass_commander_base_dir/runtime_files"
export permanent_files_dir="$mass_commander_base_dir/permanent_files"
export sftp_username="sftpuser"
perm_ip_addr_with_sub_mask=$(cat $permanent_files_dir/permanent_ip_address_with_subnet_mask)
export sftp_server_ip=$(echo $perm_ip_addr_with_sub_mask | awk -F'/' '{print $1}')
export sftp_directory="/data"
export sftp_accessing_private_key_name="key_for_accessing_sftp_server"

one_doing_remover() {
	while read username; do
		su - $username -c 'rm one_doing'
	done<$runtime_files_dir/running_usernames
}

running_users_finder() {
	w > $runtime_files_dir/w_output
	no_of_lines_in_w_output=$(wc -l $runtime_files_dir/w_output | awk -F' ' '{print $1}')
	sed -n 3,${no_of_lines_in_w_output}p $runtime_files_dir/w_output > $runtime_files_dir/running_users_details
	cat $runtime_files_dir/running_users_details | awk -F' ' '{print $1}' > $runtime_files_dir/running_usernames
}


command_output_file_ensurer() {
	if [ -f /home/command_output ]; then
		rm /home/command_output
		touch /home/command_output
	else
		touch /home/command_output
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

eval $(ssh_agent)
ssh_add ~/.ssh/${sftp_accessing_private_key_name}

#commands_to_run file fetcher
cd $runtime_files_dir
sftp -o StrictHostKeyChecking=no $sftp_username@$sftp_server_ip <<< $"get $sftp_directory/commands_to_run_of_client"
cd -

running_users_finder
one_doing_remover

source $runtime_files_dir/commands_to_run_of_client>/home/command_output 2>&1
