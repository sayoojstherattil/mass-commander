#!/bin/bash



echo -ne "Enter usernames to act on:\n"

while read username; do
	echo "$username" >> $runtime_files_dir/normal-users-to-run-commands
done
