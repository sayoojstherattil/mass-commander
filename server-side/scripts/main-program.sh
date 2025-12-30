#!/bin/bash

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
export sftp_directory=/srv/sftpuser/data
export sftp_dir_for_client=/data

export sftp_username="sftpuser"
export sftp_server_ip="172.17.103.254"
export permanent_files_dir="$mass_commander_base_dir/permanent-files"

export PATH="$PATH:$mass_commander_base_dir/scripts"

directory_ensurer $runtime_files_dir
directory_ensurer $runtime_files_dir/snap-packages-fetching-area


echo "What would you like to do?"
echo "(i)nstall packages"
echo "(r)emove packages"
echo "(a)dd users"
echo "(d)elete users"
echo "(c)ustom commanding"

echo -ne "i\nr\na\nd\nc\n" > $runtime_files_dir/input-options
user-input-validator.sh

user_input=$(cat $runtime_files_dir/user-input)

if [ "$user_input" = "i" ]; then
	user_choice="install_packages"
fi

if [ "$user_input" = "r" ]; then
	user_choice="remove_packages"
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

if [ "$user_choice" = "add_users" ]; then
	user-adder.sh
elif [ "$user_choice" = "delete_users" ]; then
	user-deletor.sh
elif [ "$user_choice" = "install_packages" ]; then
	packages-installer.sh
elif [ "$user_choice" = "remove_packages" ]; then
	packages-remover.sh
elif [ "$user_choice" = "custom_commanding" ]; then
	custom-commander.sh
fi
