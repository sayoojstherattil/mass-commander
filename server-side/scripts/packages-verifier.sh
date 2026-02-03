#!/bin/bash

packages_distinguisher() {
	while read package_name; do
		snap_finder_output=$(grep -e "$package_name/" $runtime_files_dir/apt-search-output -A1 | grep -w snap | awk -F'-> ' '{print $2}' | awk -F' snap' '{print $1}')

		if [ "$snap_finder_output" != "" ]; then
			echo $snap_finder_output >> $runtime_files_dir/snap-packages
		fi
	done<$runtime_files_dir/packages-names-given-by-user

	if [ -f $runtime_files_dir/snap-packages ]; then
		cat $runtime_files_dir/packages-names-given-by-user | grep -vf $runtime_files_dir/snap-packages > $runtime_files_dir/apt-packages
	else
		cp $runtime_files_dir/packages-names-given-by-user $runtime_files_dir/apt-packages	
	fi
}

packages_verifier() {
	echo
	echo "verifying package names..."
	echo
	while read package_name; do
		apt search $package_name >> $runtime_files_dir/apt-search-output 2>/dev/null
		grep -qe "^$package_name/" $runtime_files_dir/apt-search-output

		if [ $? = 0 ]; then
			echo 0 > $runtime_files_dir/status
		else
			echo "no package $package_name found"
			echo 1 > $runtime_files_dir/status
		fi
	done<$runtime_files_dir/packages-names-given-by-user
}

user_inputer() {
	echo "enter the names of packages:"

	while read package_name; do 
		echo $package_name >> $runtime_files_dir/packages-names-given-by-user
	done
}

user_inputer
packages_verifier
packages_distinguisher
