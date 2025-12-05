#!/bin/bash

directory_ensurer() {
	dir_name="$1"

	if [ -d $dir_name ]; then
		rm -r $dir_name
		mkdir $dir_name

		echo "recreated $dir_name"
	else
		mkdir $dir_name

		echo "made $dir_name"
	fi
}

necessary_directories_ensurer() {
	directory_ensurer "$runtime_files_dir"
	directory_ensurer "$runtime_files_dir/files-tarring-area"
	directory_ensurer "$runtime_files_dir/local-repo-creation"
}

script_necessary_variables_changer() {
	export PATH="$PATH:/root/mass-commander/scripts"
	export runtime_files_dir="/root/mass-commander/runtime-files"
	export runtime_files_dir_of_client="/root/mass-commander/runtime-files"
	export permanent_files_dir="/root/mass-commander/permanent-files"
}


script_necessary_variables_changer
necessary_directories_ensurer

#prompter
prompt.sh

user_choice=$(cat $runtime_files_dir/user-choice)

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
