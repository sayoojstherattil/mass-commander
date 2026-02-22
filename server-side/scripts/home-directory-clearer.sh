#!/bin/bash

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
	commands-for-clients-to-run.sh "	mkdir -v $(cat $permanent_files_dir/default-folders | tr ' ' '\n')"
	commands-for-clients-to-run.sh "done<$runtime_files_dir_of_client/actual-normal-users"
}

actual_normal_users_finder
home_dir_clearer

commander.sh
