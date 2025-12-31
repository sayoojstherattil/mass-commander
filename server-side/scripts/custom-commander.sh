#!/bin/bash

command_generator_for_acting_on_normal_users() {
	while read username; do
		commands-for-clients-to-run.sh "su - $username -c '"
		commands-for-clients-to-run.sh "$(cat $runtime_files_dir/custom-commands)"
		commands-for-clients-to-run.sh "'"
	done<$runtime_files_dir/normal-users-to-run-commands
}

custom_commands_fetcher() {
	echo "Enter the commands one by one and hit enter"
	while read entered_command; do
		#special_character_detector
		echo "$entered_command" | grep -qe '"' || echo "$entered_command" | grep -qe "'"
		if [ $? = 0 ]; then
			echo "please don't use quotations"
		else
			echo "$entered_command" >> custom-commands
		fi
	done
}

normal_usernames_fetcher() {
	echo "Enter usernames to act on:"

	while read username; do
		echo "$username" >> $runtime_files_dir/normal-users-to-run-commands
	done
}


echo "how would you like to login? (r)oot or (n)ormal user?"
echo -ne "r\nn\n" > $runtime_files_dir/input-options

user-input-validator.sh

user_input=$(cat $runtime_files_dir/user-input)

if [ "$user_input" = "n" ]; then
	normal_usernames_fetcher
	custom_commands_fetcher
	command_generator_for_acting_on_normal_users
elif [ "$user_input" = "r" ]; then
	custom_commands_fetcher
	commands-for-clients-to-run.sh "$(cat $runtime_files_dir/custom-commands)"
fi

commander.sh
