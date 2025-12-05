#!/bin/bash

echo "Enter usernames to act on:"

while read username; do
	echo "$username" >> $runtime_files_dir/normal-users-to-run-commands
done
