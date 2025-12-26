#!/bin/bash

snap_package_fetcher() {
	
}

snap_package_dealer() {
	snap_finder_output=$(apt search $package_name | grep -e '$package_name/' -A1 | grep -w snap | awk -F'-> ' '{print $2}' | awk -F' snap' '{print $1}')

	if [ $snap_finder_output -z ]; then
		snap_package_existence=no
		
		installation_method=apt
	else
		snap_package_existence=yes
		snap_package_name=$snap_finder_output

		installation_method=snap
	fi
}

user_inputer() {
	echo "enter the names of packages:"

	while read package_name; do 
		echo $package_name >> $runtime_files_dir/packages-names-given-by-user
	done
}


# main
user_inputer
snap_package_dealer

if [ $installation_method -eq snap ]; then
	snap_package_fetcher
	snap_installation_method_command_generator
elif [ $installation_method -eq apt ]; then
	apt_installation_method_command_generator
fi
