#!/bin/bash -x

commands_generator() {
	commands-for-clients-to-run.sh "wget -P $runtime_files_dir ftp://$server_ip_address/snap_assert_packages_fetched"
	commands-for-clients-to-run.sh "wget -P $runtime_files_dir ftp://$server_ip_address/snap_installable_packages_fetched"

	commands-for-clients-to-run.sh ''

	if [ $no_of_lines_in_snap_package_names_file -ne 0 ]; then

		commands-for-clients-to-run.sh 'while read snap_assert_package; do'
		commands-for-clients-to-run.sh 'snap ack $snap_assert_package'
		commands-for-clients-to-run.sh "done<$runtime_files_dir_for_client/snap_assert_packages_fetched"

		commands-for-clients-to-run.sh 'while read snap_installable_package; do'
		commands-for-clients-to-run.sh 'snap install $snap_installable_package'
		commands-for-clients-to-run.sh "done<$runtime_files_dir_for_client/snap_installable_packages_fetched"
	fi


	commands-for-clients-to-run.sh "apt install $(cat $runtime_files_dir/apt-packages)"
}

installable_and_assert_snap_packages_distinguisher() {
	while read snap_package; do
		if [ echo $snap_package | grep -e '.assert' ]; then
			echo $snap_package | tee -a $runtime_files_dir/snap_assert_packages_fetched
		elif [ echo $snap_package | grep -e '.snap' ]; then
			echo $snap_package | tee -a $runtime_files_dir/snap_installable_packages_fetched
		fi
	done<$runtime_files_dir/snap_packages_fetched
}

snap_packages_in_ftp_directory_placer() {
	ls $runtime_files_dir/snap-packages-fetching-area > $runtime_files_dir/snap_packages_fetched

	while read snap_package; do
		mv $runtime_files_dir/snap-packages-fetching-area$snap_package $ftp_directory
	done<$runtime_files_dir/snap_packages_fetched
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
			echo snap is present
			echo $package_name | tee -a $runtime_files_dir/snap-packages
		fi
	done<$runtime_files_dir/packages-names-given-by-user
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

exit 0


if [ $snap_package_existance = 1 ]; then
	snap_package_fetcher
fi

snap_packages_in_ftp_directory_placer
commands_generator

commander.sh
