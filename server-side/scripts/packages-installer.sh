#!/bin/bash

snap_packages_install_command_generator() {
	commands-for-clients-to-run.sh "cd $runtime_files_dir_of_client"


	commands-for-clients-to-run.sh "echo installing snap $snap_package"

	while read snap_package; do
		commands-for-clients-to-run.sh "snap install $snap_package"
	done<$runtime_files_dir/installable-snap-packages

	commands-for-clients-to-run.sh "cd - >/dev/null"
}

snap_packages_acknowledge_command_generator() {
	commands-for-clients-to-run.sh "cd $runtime_files_dir_of_client"

	while read snap_package; do
		commands-for-clients-to-run.sh "snap ack $snap_package"
	done<$runtime_files_dir/assert-snap-packages

	commands-for-clients-to-run.sh "cd - >/dev/null"
}

snap_packages_fetching_command_generator() {
	commands-for-clients-to-run.sh "cd $runtime_files_dir_of_client"

	while read snap_package; do
		commands-for-clients-to-run.sh "sftp $sftp_username@$sftp_server_ip <<< $'get /data/$snap_package'"
	done<$runtime_files_dir/actual-names-of-snap-packages

	commands-for-clients-to-run.sh "cd - >/dev/null"
}

snap_packages_distinguisher() {
	while read snap_package; do
		echo "$snap_package" | grep -qe '\.assert'
		if [ $? = 0 ]; then
			echo "$snap_package" >> $runtime_files_dir/assert-snap-packages
		fi

		echo "$snap_package" | grep -qe '\.snap'
		if [ $? = 0 ]; then
			echo "$snap_package" >> $runtime_files_dir/installable-snap-packages
		fi
	done<$runtime_files_dir/actual-names-of-snap-packages
}

commands_generator() {
	if [ -f $runtime_files_dir/snap-packages ]; then
		no_of_lines_in_snap_package_names_file=$(wc -l $runtime_files_dir/snap-packages | awk -F' ' '{print $1}')

		if [ $no_of_lines_in_snap_package_names_file != 0 ]; then
			snap_packages_distinguisher
			snap_packages_fetching_command_generator
			snap_packages_acknowledge_command_generator
			snap_packages_install_command_generator
		fi
	fi

	if [ -f $runtime_files_dir/apt-packages ]; then
		commands-for-clients-to-run.sh "echo installing $apt_package_name"

		while read apt_package_name; do
			commands-for-clients-to-run.sh "apt update"
			commands-for-clients-to-run.sh "apt install -y $apt_package_name"
		done<$runtime_files_dir/apt-packages
	fi
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

sftp_directory_files_permission_changer() {
	ls $sftp_directory > $runtime_files_dir/files-in-sftp

	while read filename; do
		chmod 644 ${sftp_directory}/${filename}
	done<$runtime_files_dir/files-in-sftp
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
		
	cd  - >/dev/null

	echo
}


# main
packages-verifier.sh

status=$(cat $runtime_files_dir/status)

if [ $status = "1" ]; then
	exit 1
fi

if [ -f $runtime_files_dir/snap-packages ]; then
	snap_package_fetcher
fi

snap_packages_in_ftp_directory_placer
sftp_directory_files_permission_changer
commands_generator

commander.sh
