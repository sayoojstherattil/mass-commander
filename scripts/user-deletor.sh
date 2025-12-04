#!/bin/bash


echo "executing user deletor"

echo "enter usernames one by one: "
while read username; do
	echo "userdel $username -r" >> $runtime_files_dir/commands-to-run
done

commander.sh
