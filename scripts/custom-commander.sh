#!/bin/bash

echo -ne "how would you like to login? (r)oot or (n)ormal user?"
echo -ne "r\nn\n" > $runtime_files_dir/input-options
user-input-validator.sh

echo -ne "Enter the commands one by one and hit enter\n"

while read entered_command; do
	echo "$entered_command" >> $runtime_files_dir/custom-commands
done

user_input=$(cat $runtime_files_dir/user-input)

if [ "$user_input" = "n" ]; then
	user-fetcher.sh
	
	while read username; do
		commands-to-run.sh "su - $username -c ' \\"
		commands-to-run.sh $(cat $runtime_files_dir/custom-commands)
		commands-to-run.sh "'"
	done<$runtime_files_dir/normal-users-to-run-commands
else
	commands-to-run.sh $(cat $runtime_files_dir/custom-commands)
fi

commander.sh
