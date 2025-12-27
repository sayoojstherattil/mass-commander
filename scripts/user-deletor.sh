#!/bin/bash

echo "enter usernames one by one: "
while read username; do
	echo "userdel $username -r" >> $runtime_files_dir/commands-for-client-root-to-run
done

commander.sh
