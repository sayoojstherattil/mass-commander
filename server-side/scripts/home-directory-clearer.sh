#!/bin/bash

systems_reboot_prompt() {
	echo "rebooting systems is necessary to perform the operation"
	echo "proceed? (y)/(n)"
	echo

	echo -ne "y\nn\n" > $runtime_files_dir/input-options
	user-input-validator.sh
	user_input=$(cat $runtime_files_dir/user-input)

	if [ "$user_input" = "y" ]; then
		echo -n "be careful not to use the computers until the second reboot which will happen automatically [press enter to continue]"
		read tmp
		systems-rebooter.sh
	elif [ "$user_input" = "n" ]; then
		echo "aborting the operation..."
		exit 1
	fi
}

actual_normal_users_finder() {
	commands-for-clients-to-run.sh "ls /home | tee -a $runtime_files_dir_of_client/home-dir-files"

	commands-for-clients-to-run.sh "grep -f $runtime_files_dir_of_client/home-dir-files /etc/shadow | awk -F':' '{print \$1}' > $runtime_files_dir_of_client/actual-normal-users"
}

home_dir_clearer() {
	commands-for-clients-to-run.sh "while read username; do"
	commands-for-clients-to-run.sh "	rm -v -rf /home/\${username}"
	commands-for-clients-to-run.sh "	mkhomedir_helper \${username}"
	commands-for-clients-to-run.sh "	(cat $mass_commander_base_dir/scripts/profile-last-part | tee -a /home/\${username}/.profile) >/dev/null"
	commands-for-clients-to-run.sh "	chown \${username}:\${username} /home/\${username}/.profile"
	commands-for-clients-to-run.sh "	cd /home/\${username}"
	commands-for-clients-to-run.sh "	mkdir -v $(cat $permanent_files_dir/default-folders | tr '\n' ' ')"
	commands-for-clients-to-run.sh "done<$runtime_files_dir_of_client/actual-normal-users"
}

systems_reboot_prompt

actual_normal_users_finder
home_dir_clearer
commander.sh

systems-rebooter.sh
