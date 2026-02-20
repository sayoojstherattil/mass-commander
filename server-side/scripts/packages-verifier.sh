#!/bin/bash

apt_packages_verification() {
	echo "enter apt packages names:"
	while read package_name; do 
		echo $package_name >> $runtime_files_dir/apt_package_names_given_by_user
	done

	echo
	echo "verifying package names..."
	echo
	while read package_name; do
		apt-cache show $package_name >/dev/null

		if [ $? -eq 0 ]; then
			echo 0 > $runtime_files_dir/status
			echo "$package_name" | tee -a $runtime_files_dir/verified_apt_package_names
		else
			echo "no package $package_name found"
			echo 1 > $runtime_files_dir/status
			exit 1
		fi
	done<$runtime_files_dir/apt_package_names_given_by_user
}

snap_packages_verification() {
	echo "enter snap packages names:"
	while read package_name; do 
		echo $package_name >> $runtime_files_dir/snap_package_names_given_by_user
	done

	echo
	echo "verifying package names..."
	echo
	while read package_name; do
		snap info $package_name >/dev/null

		if [ $? -eq 0 ]; then
			echo 0 > $runtime_files_dir/status
			echo "$package_name" | tee -a $runtime_files_dir/verified_snap_package_names
		else
			echo "no package $package_name found"
			echo 1 > $runtime_files_dir/status
			exit 1
		fi
	done<$runtime_files_dir/snap_package_names_given_by_user
}


echo "what kind of package do you wish to install"
echo "(s)nap"
echo "(a)pt"
echo
echo -ne "s\na\n" > $runtime_files_dir/input-options
user-input-validator.sh
user_input=$(cat $runtime_files_dir/user-input)
if [ "$user_input" = "a" ]; then
	apt_packages_verification
elif [ "$user_input" = "s" ]; then
	snap_packages_verification
fi
