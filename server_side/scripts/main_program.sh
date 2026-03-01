#!/bin/bash

sftp_directory_clearer() {
	ls $sftp_directory > $runtime_files_dir/files_in_sftp_directory	
	
	while read filename; do
		rm $sftp_directory/$filename
	done<$runtime_files_dir/files_in_sftp_directory
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

export mass_commander_base_dir=/root/mass_commander
export runtime_files_dir=$mass_commander_base_dir/runtime_files
export runtime_files_dir_of_client=$mass_commander_base_dir/runtime_files
export permanent_files_dir=$mass_commander_base_dir/permanent_files
export sftp_directory=/srv/sftpuser/data
export sftp_dir_of_client=/data

export sftp_username="sftpuser"
perm_ip_addr_with_sub_mask=$(cat $permanent_files_dir/permanent_ip_address_with_subnet_mask)
export sftp_server_ip=$(echo $perm_ip_addr_with_sub_mask | awk -F'/' '{print $1}')
export permanent_files_dir="$mass_commander_base_dir/permanent_files"

export PATH="$PATH:$mass_commander_base_dir/scripts"

export clients_accesing_private_key="/root/.ssh/key_for_accessing_client_machines"

directory_ensurer $runtime_files_dir
directory_ensurer $runtime_files_dir/snap_packages_fetching_area

sftp_directory_clearer

commands_for_clients_to_run.sh "set -e"

eval $(ssh_agent) >/dev/null 2>&1
ssh_add ${clients_accesing_private_key} >/dev/null 2>&1

echo "What would you like to do?"
echo "(i)nstall packages"
echo "(r)emove packages"
echo "(u)pgrade packages"
echo "(a)dd users"
echo "(d)elete users"
echo "(c)ustom commanding"
echo ""
echo "(S)hutdown systems"
echo "(R)eboot systems"
echo "(H)ome dirs clearer"

echo -ne "i\nr\nu\na\nd\nc\nS\nR\nH\n" > $runtime_files_dir/input_options
user_input_validator.sh
echo

user_input=$(cat $runtime_files_dir/user_input)

if [ "$user_input" = "i" ]; then
	packages_installer.sh
elif [ "$user_input" = "r" ]; then
	packages_remover.sh
elif [ "$user_input" = "u" ]; then
	packages_upgrader.sh
elif [ "$user_input" = "a" ]; then
	user_adder.sh
elif [ "$user_input" = "d" ]; then
	user_deletor.sh
elif [ "$user_input" = "c" ]; then
	custom_commander.sh
elif [ "$user_input" = "S" ]; then
	systems_shutdowner.sh
elif [ "$user_input" = "R" ]; then
	systems_rebooter.sh
elif [ "$user_input" = "H" ]; then
	home_directory_clearer.sh
fi
