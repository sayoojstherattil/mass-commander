#!/bin/bash

echo "how would you like to login? (r)oot or (n)ormal user?"
echo -n "enter choice: "
echo -ne "r\nn\n" > $runtime_files_dir/input-options
user-input-validator.sh

echo "Enter the commands one by one and hit enter:"

while read entered_command; do
	echo "$entered_command" >> $runtime_files_dir/custom-commands
done

files-to-tar.sh "$runtime_files_dir/custom-commands"

user_input=$(cat $runtime_files_dir/user-input)

if [ "$user_input" = "n" ]; then
	user-fetcher.sh
	
	while read username; do
		commands-to-run.sh "su - $username -c 'source $runtime_files_dir/files-from-server/custom-commands'"
	done<$runtime_files_dir/normal-users-to-run-commands
else
	commands-to-run.sh "source $runtime_files_dir/custom-commands"
fi

commander.sh
