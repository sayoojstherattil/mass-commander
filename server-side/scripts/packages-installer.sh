#!/bin/bash -x

snap_packages_install_command_generator() {
	commands_for_clients_to_run.sh "cd $runtime_files_dir_of_client"

	while read snap_package; do
		commands_for_clients_to_run.sh "snap install $snap_package"
	done<$runtime_files_dir/snap_packages_installation_candidate_names

	commands_for_clients_to_run.sh "cd _"
}

snap_packages_acknowledge_command_generator() {
	commands_for_clients_to_run.sh "cd $runtime_files_dir_of_client"

	while read snap_package; do
		commands_for_clients_to_run.sh "snap ack $snap_package"
	done<$runtime_files_dir/assert_snap_packages

	commands_for_clients_to_run.sh "cd _"
}

snap_packages_fetching_command_generator() {
	commands_for_clients_to_run.sh "cd $runtime_files_dir_of_client"

	while read snap_package; do
		commands_for_clients_to_run.sh "sftp $sftp_username@$sftp_server_ip <<< $'get /data/$snap_package'"
	done<$runtime_files_dir/actual_names_of_snap_packages

	commands_for_clients_to_run.sh "cd _"
}

snap_packages_distinguisher() {
	while read snap_package; do
		echo "$snap_package" | grep -qe '\.assert'
		if [ $? = 0 ]; then
			echo "$snap_package" >> $runtime_files_dir/assert_snap_packages
		fi

		echo "$snap_package" | grep -qe '\.snap'
		if [ $? = 0 ]; then
			echo "$snap_package" >> $runtime_files_dir/installable_snap_packages
		fi
	done<$runtime_files_dir/actual_names_of_snap_packages
}

installable_and_assert_snap_packages_distinguisher() {
	while read actual_snap_package_name; do
		echo $actual_snap_package_name | grep -qe '.assert'
		if [ $? = 0 ]; then
			echo $actual_snap_package_name >> $runtime_files_dir/assert_snap_packages_fetched
		fi

		echo $actual_snap_package_name | grep -qe '.snap'
		if [ $? = 0 ]; then
			echo $actual_snap_package_name >> $runtime_files_dir/installable_snap_packages_fetched
		fi
	done<$runtime_files_dir/actual_names_of_snap_packages
}

snap_packages_in_sftp_directory_placer() {
	while read actual_snap_package_name; do
		cp $snap_packages_archive_directory/$actual_snap_package_name $sftp_directory
	done<$runtime_files_dir/actual_names_of_snap_packages
}

snap_package_fetcher() {
	while read installation_candidate_names_of_snap_package; do
		ls $snap_packages_archive_directory > $runtime_files_dir/snap_packages_archive_contents
		actual_snap_package_name=$(grep $runtime_files_dir/snap_packages_archive_contents -e "$installation_candidate_names_of_snap_packages")
		
		if [ $? = 0 ]; then
			echo "package $actual_snap_package_name exists"
			echo -n "Replace? (y)/(n) "

			echo -ne "y\nn\n" > $runtime_files_dir/input_options
			user_input_validator.sh

			user_input=$(cat $runtime_files_dir/user_input)
		fi

		if [ $package_replace_choice = "y" ]; then
			rm $snap_packages_archive_directory/$actual_snap_package_name

			cd $snap_packages_archive_directory
			snap download $installation_candidate_names_of_snap_package
			cd -
		else
			echo "$actual_snap_package_name" >> $runtime_files_dir/actual_names_of_snap_packages
		fi
	done<$runtime_files_dir/installation_candidate_names_of_snap_packages
}

packages_distinguisher() {
	snap_package_existance=0

	while read valid_package_name; do
		installation_candidate_name_of_snap_package=$(grep -e "$package_name/" $runtime_files_dir/apt_search_output_of_${valid_package_name} -A1 | grep -w snap | awk -F'-> ' '{print $2}' | awk -F' snap' '{print $1}')

		if [ "$installation_candidate_name_of_snap_package" != "" ]; then
			echo $installation_candidate_name_of_snap_package >> $runtime_files_dir/installation_candidate_names_of_snap_packages
		fi
	done<$runtime_files_dir/packages_names_given_by_user

	# apt package installation candidate names finder
	if [ -f $runtime_files_dir/installation_candidate_names_of_snap_packages ]; then
		cat $runtime_files_dir/packages_names_given_by_user | grep -vf $runtime_files_dir/installation_candidate_names_of_snap_packages > $runtime_files_dir/installation_candidate_names_of_apt_packages
	else
		#no snap packages exist
		cp $runtime_files_dir/packages_names_given_by_user $runtime_files_dir/installation_candidate_names_of_apt_packages	
	fi
}

package_searcher() {
	while read package_name_given_by_user; do
		apt search $package_name_given_by_user > $runtime_files_dir/apt_search_output_of_${package_name_given_by_user}
		grep -qe "$package_name_given_by_user/" $runtime_files_dir/apt_search_output_of_${package_name_given_by_user}

		if [ $? != 0 ]; then
			echo "no package $package_name_given_by_user found"
			exit 1
		fi
	done<$runtime_files_dir/packages_names_given_by_user
}

user_inputer() {
	echo "enter the names of packages:"

	while read read_package_name; do 
		echo $read_package_name >> $runtime_files_dir/packages_names_given_by_user
	done
}


# main
set -e
user_inputer
package_searcher
packages_distinguisher

if [ -f $runtime_files_dir/installation_candidate_names_of_snap_packages ]; then
	snap_package_fetcher
	snap_packages_distinguisher
	snap_packages_fetching_command_generator
	snap_packages_acknowledge_command_generator
	snap_packages_install_command_generator
fi

if [ -f $runtime_files_dir/apt_packages ]; then
	commands_for_clients_to_run.sh "apt install $(cat $runtime_files_dir/apt_packages)"
fi

commander.sh
