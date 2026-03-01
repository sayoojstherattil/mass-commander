#!/bin/bash

echo "what kind of package do you like to remove"
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
	while read snap_package_name; do
		commands_for_clients_to_run.sh "echo removing ${snap_package_name}..."
		commands_for_clients_to_run.sh "snap remove $snap_package_name"
	done<$runtime_files_dir/verified_snap_package_names 
fi

if [ -f $runtime_files_dir/verified_apt_package_names ]; then
	commands_for_clients_to_run.sh "apt remove -y $(cat $runtime_files_dir/verified_apt_package_names | tr '\n' ' ')"
fi

commander.sh
