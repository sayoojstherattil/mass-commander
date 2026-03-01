#!/bin/bash

snap_package_fetcher() {
	cd $sftp_directory

	while read package_name; do
		snap download $package_name
	done<$runtime_files_dir/verified_snap_package_names
		
	cd  - >/dev/null

	echo
}

snap_files_in_sftp_finder() {
	(ls $sftp_directory | tee $runtime_files_dir/snap_packages_in_sftp) >/dev/null
}

snap_packages_distinguisher() {
	while read snap_package; do
		echo "$snap_package" | grep -qe '\.assert'
		if [ $? = 0 ]; then
			(echo "$snap_package" | tee -a $runtime_files_dir/assert_snap_packages) >/dev/null
		fi

		echo "$snap_package" | grep -qe '\.snap'
		if [ $? = 0 ]; then
			(echo "$snap_package" | tee -a $runtime_files_dir/installable_snap_packages) >/dev/null
		fi
	done<$runtime_files_dir/snap_packages_in_sftp
}

snap_packages_fetching_command_generator() {
	commands_for_clients_to_run.sh "cd $runtime_files_dir_of_client"

	while read installable_snap_package; do
		commands_for_clients_to_run.sh "sftp $sftp_username@$sftp_server_ip <<< $'get /data/$installable_snap_package'"
	done<$runtime_files_dir/installable_snap_packages

	while read assert_snap_package; do
		commands_for_clients_to_run.sh "sftp $sftp_username@$sftp_server_ip <<< $'get /data/$assert_snap_package'"
	done<$runtime_files_dir/assert_snap_packages

	commands_for_clients_to_run.sh "cd - >/dev/null"
}

snap_packages_acknowledge_command_generator() {
	commands_for_clients_to_run.sh "cd $runtime_files_dir_of_client"

	while read assert_snap_package; do
		commands_for_clients_to_run.sh "echo asserting snap $assert_snap_package"
		commands_for_clients_to_run.sh "snap ack $assert_snap_package"
	done<$runtime_files_dir/assert_snap_packages

	commands_for_clients_to_run.sh "cd - >/dev/null"
}

snap_packages_install_command_generator() {
	commands_for_clients_to_run.sh "cd $runtime_files_dir_of_client"

	while read installable_snap_package; do 
		commands_for_clients_to_run.sh "echo installing snap $installable_snap_package"
		commands_for_clients_to_run.sh "snap install $installable_snap_package"
	done<$runtime_files_dir/installable_snap_packages

	commands_for_clients_to_run.sh "cd - >/dev/null"
}


# main
echo "what kind of package do you wish to install"
echo "(s)nap"
echo "(a)pt"
echo
echo -ne "s\na\n" > $runtime_files_dir/input_options
user_input_validator.sh

packages_verifier.sh

status=$(cat $runtime_files_dir/status)

if [ $status -eq 1 ]; then
	exit 1
fi

if [ -f $runtime_files_dir/verified_snap_package_names ]; then
	snap_package_fetcher
	snap_files_in_sftp_finder
	snap_packages_distinguisher
	snap_packages_fetching_command_generator
	snap_packages_acknowledge_command_generator
	snap_packages_install_command_generator
fi

if [ -f $runtime_files_dir/verified_apt_package_names ]; then
	commands_for_clients_to_run.sh "apt update"
	commands_for_clients_to_run.sh "apt install -y $(cat $runtime_files_dir/verified_apt_package_names | tr '\n' ' ')"
fi

commander.sh
