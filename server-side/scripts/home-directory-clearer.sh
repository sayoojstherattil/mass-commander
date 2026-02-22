#!/bin/bash

actual_normal_users_finder() {
	commands-for-clients-to-run.sh "ls /home | tee -a $runtime_files_dir_of_client/home-dir-folders"

	commands-for-clients-to-run.sh "grep -f $runtime_files_dir_of_client/home-dir-folders /etc/shadow | awk -F':' '{print $1}' > $runtime_files_dir_of_client/actual-normal-users"
}

home_dir_clearer() {
	commands-for-clients-to-run.sh "while read username; do"
		commands-for-clients-to-run.sh "ls -a /home/\${username} > $runtime_files_dir_of_client/contents-of-\${username}"
		commands-for-clients-to-run.sh "rm -rf '$(cat $runtime_files_dir_of_client/contents-of-\${username} | tr '\n' ' ')'"

		commands-for-clients-to-run.sh "while read folder_name; do"
			commands-for-clients-to-run.sh "mkdir /home/\${username}/$folder_name"
		commands-for-clients-to-run.sh "done<$permanent_files_dir/default-folders"
	commands-for-clients-to-run.sh "done<$runtime_files_dir_of_client/actual-normal-users"
}

actual_normal_users_finder
home_dir_clearer
