#!/bin/bash

prompt() {
	echo
	echo -n "$1 [press enter to continue]"
	read tmp
	echo
}

systems_reboot_prompt() {
	echo "rebooting systems is necessary to perform the operation"
	echo "proceed? (y)/(n)"

	echo -ne "y\nn\n" > $runtime_files_dir/input_options
	user_input_validator.sh
	user_input=$(cat $runtime_files_dir/user_input)

	if [ "$user_input" = "y" ]; then
		prompt 'be careful not to use the computers until the second reboot which will happen automatically'
		systems_rebooter.sh
	elif [ "$user_input" = "n" ]; then
		echo "aborting the operation..."
		exit 1
	fi
}

systems_back_on_ensurer() {
	prompt "ensure that all systems are back on the login screen"
}

commands_to_run_of_client_file_clearer() {
	rm $runtime_files_dir/commands_to_run_of_client
}

actual_normal_users_finder() {
	(commands_for_clients_to_run.sh "ls /home | tee -a $runtime_files_dir_of_client/home_dir_files") >/dev/null

	commands_for_clients_to_run.sh "grep -f $runtime_files_dir_of_client/home_dir_files /etc/shadow | awk -F':' '{print \$1}' > $runtime_files_dir_of_client/actual_normal_users"
}

home_dir_clearer() {
	commands_for_clients_to_run.sh "while read username; do"
	commands_for_clients_to_run.sh "	rm -v -rf /home/\${username}"
	commands_for_clients_to_run.sh "	mkhomedir_helper \${username}"
	(commands_for_clients_to_run.sh "	(cat $mass_commander_base_dir/scripts/profile_last_part | tee -a /home/\${username}/.profile) >/dev/null") >/dev/null
	commands_for_clients_to_run.sh "	chown \${username}:\${username} /home/\${username}/.profile"
	commands_for_clients_to_run.sh "	cd /home/\${username}"
	commands_for_clients_to_run.sh "	mkdir -v $(cat $permanent_files_dir/default_folders | tr '\n' ' ')"
	commands_for_clients_to_run.sh "done<$runtime_files_dir_of_client/actual_normal_users"

	commands_for_clients_to_run.sh "systemctl reboot"
}

systems_reboot_prompt

systems_back_on_ensurer

echo 'clearing home folders...'

commands_to_run_of_client_file_clearer
actual_normal_users_finder
home_dir_clearer

commander.sh
