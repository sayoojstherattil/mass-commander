#!/bin/bash -xe

snap_packages_fetching_command_generator() {
	echo values are... 
	echo $sftp_username

	commands-for-clients-to-run.sh "cd $runtime_files_dir_for_client/snap-packages-from-server"

	while read snap_package; do
		commands-for-clients-to-run.sh ""

		commands-for-clients-to-run.sh "sftp $sftp_username@$sftp_server_ip<<EOF"
		commands-for-clients-to-run.sh "get $sftp_dir_for_client/$snap_package"

		commands-for-clients-to-run.sh ""
	done<$runtime_files_dir/actual-names-of-snap-packages

	commands-for-clients-to-run.sh "cd -"
}

commands_generator() {
	no_of_lines_in_snap_package_names_file=$(wc -l $runtime_files_dir/snap-packages | awk -F' ' '{print $1}')

	if [ $no_of_lines_in_snap_package_names_file != 0 ]; then
		snap_packages_fetching_command_generator
	fi

	commands-for-clients-to-run.sh "apt install $(cat $runtime_files_dir/apt-packages)"
}

installable_and_assert_snap_packages_distinguisher() {
	while read snap_package; do
		if [ echo $snap_package | grep -e '.assert' ]; then
			echo $snap_package >> $runtime_files_dir/snap_assert_packages_fetched
		elif [ echo $snap_package | grep -e '.snap' ]; then
			echo $snap_package >> $runtime_files_dir/snap_installable_packages_fetched
		fi
	done<$runtime_files_dir/actual-names-of-snap-packages
}

snap_packages_in_ftp_directory_placer() {
	ls $runtime_files_dir/snap-packages-fetching-area > $runtime_files_dir/actual-names-of-snap-packages

	while read snap_package; do
		mv $runtime_files_dir/snap-packages-fetching-area/$snap_package $sftp_directory
	done<$runtime_files_dir/actual-names-of-snap-packages
}

snap_package_fetcher() {
	cd $runtime_files_dir/snap-packages-fetching-area

	while read package_name; do
		snap download $package_name
	done<$runtime_files_dir/snap-packages
		
	cd  -
}

packages_distinguisher() {
	snap_package_existance=0

	while read package_name; do
		snap_finder_output=$(grep -e "$package_name/" $runtime_files_dir/apt-search-output -A1 | grep -w snap | awk -F'-> ' '{print $2}' | awk -F' snap' '{print $1}')

		echo snap finder output is $snap_finder_output

		if [ "$snap_finder_output" != "" ]; then
			snap_package_existance=1
			echo $package_name >> $runtime_files_dir/snap-packages
		fi
	done<$runtime_files_dir/packages-names-given-by-user

	cat $runtime_files_dir/packages-names-given-by-user | grep -vf $runtime_files_dir/snap-packages > $runtime_files_dir/apt-packages
}

package_searcher() {
	while read package_name; do
		apt search $package_name >> $runtime_files_dir/apt-search-output
		grep -qe "$package_name/" $runtime_files_dir/apt-search-output

		if [ $? = 0 ]; then
			package_existance=1
		else
			package_existance=0

			echo "no package $package_name found"
			exit 1
		fi
	done<$runtime_files_dir/packages-names-given-by-user
}

user_inputer() {
	echo "enter the names of packages:"

	while read package_name; do 
		echo $package_name >> $runtime_files_dir/packages-names-given-by-user
	done
}


# main
user_inputer
package_searcher
packages_distinguisher


if [ $snap_package_existance = 1 ]; then
	snap_package_fetcher
fi

snap_packages_in_ftp_directory_placer
commands_generator

#commander.sh
