#!/bin/bash

empty_file_remover() {
		file_loc="$1"

		no_of_lines=$(wc -l "$file_loc" | awk -F' ' '{print $1}')

		[ $no_of_lines -eq 0 ] && rm $file_loc
}

packages_distinguisher() {
	while read package_name; do
		apt search $package_name >$runtime_files_dir/apt-search-output
		snap_finder_output=$(grep -e "$package_name/" $runtime_files_dir/apt-search-output -A1 | grep -w snap | awk -F'-> ' '{print $2}' | awk -F' snap' '{print $1}')

		if [ "$snap_finder_output" != "" ]; then
			echo $snap_finder_output >> $runtime_files_dir/snap-packages
#----------------------------------------------------------------------
# remove snap-packages file if it doesn't contain anything
#----------------------------------------------------------------------
			empty_file_remover "$runtime_files_dir/snap-packages"
		fi
	done<$runtime_files_dir/packages-names-given-by-user

	if [ -f $runtime_files_dir/snap-packages ]; then
		cat $runtime_files_dir/packages-names-given-by-user | grep -vf $runtime_files_dir/snap-packages > $runtime_files_dir/apt-packages

#----------------------------------------------------------------------
# remove apt-packages file if it doesn't contain anything
#----------------------------------------------------------------------
		empty_file_remover "$runtime_files_dir/apt-packages"
	else
		cp $runtime_files_dir/packages-names-given-by-user $runtime_files_dir/apt-packages	
	fi
}

packages_verifier() {
	echo
	echo "verifying package names..."
	echo
	while read package_name; do
		apt-cache show $package_name >/dev/null

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
