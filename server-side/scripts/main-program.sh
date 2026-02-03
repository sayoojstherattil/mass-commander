#!/bin/bash

sftp_directory_clearer() {
	ls $sftp_directory > $runtime_files_dir/files-in-sftp-directory	
	
	while read filename; do
		rm $sftp_directory/$filename
	done<$runtime_files_dir/files-in-sftp-directory
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

export mass_commander_base_dir=/root/mass-commander
export runtime_files_dir=$mass_commander_base_dir/runtime-files
export runtime_files_dir_of_client=$mass_commander_base_dir/runtime-files
export permanent_files_dir=$mass_commander_base_dir/permanent-files
export sftp_directory=/srv/sftpuser/data
export sftp_dir_of_client=/data

export sftp_username="sftpuser"
perm_ip_addr_with_sub_mask=$(cat $permanent_files_dir/permanent-ip-address-with-subnet-mask)
export sftp_server_ip=$(echo $perm_ip_addr_with_sub_mask | awk -F'/' '{print $1}')
export permanent_files_dir="$mass_commander_base_dir/permanent-files"

export PATH="$PATH:$mass_commander_base_dir/scripts"

export clients_accesing_private_key="/root/.ssh/clients"

directory_ensurer $runtime_files_dir
directory_ensurer $runtime_files_dir/snap-packages-fetching-area

sftp_directory_clearer

commands-for-clients-to-run.sh "set -e"

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

echo -ne "i\nr\nu\na\nd\nc\nS\nR\n" > $runtime_files_dir/input-options
user-input-validator.sh
echo

user_input=$(cat $runtime_files_dir/user-input)

if [ "$user_input" = "i" ]; then
	user_choice="install_packages"
fi

if [ "$user_input" = "r" ]; then
	user_choice="remove_packages"
fi

if [ "$user_input" = "u" ]; then
	user_choice="upgrade_packages"
fi

if [ "$user_input" = "a" ]; then
	user_choice="add_users"
fi

if [ "$user_input" = "d" ]; then
	user_choice="delete_users"
fi

if [ "$user_input" = "c" ]; then
	user_choice="custom_commanding"
fi

if [ "$user_input" = "S" ]; then
	user_choice="shutdown_systems"
fi

if [ "$user_input" = "R" ]; then
	user_choice="reboot_systems"
fi

if [ "$user_choice" = "add_users" ]; then
	user-adder.sh
elif [ "$user_choice" = "delete_users" ]; then
	user-deletor.sh
elif [ "$user_choice" = "install_packages" ]; then
	packages-installer.sh
elif [ "$user_choice" = "remove_packages" ]; then
	packages-remover.sh
elif [ "$user_choice" = "upgrade_packages" ]; then
	packages-upgrader.sh
elif [ "$user_choice" = "custom_commanding" ]; then
	custom-commander.sh
elif [ "$user_choice" = "shutdown_systems" ]; then
	systems-shutdowner.sh
elif [ "$user_choice" = "reboot_systems" ]; then
	systems-rebooter.sh
fi
