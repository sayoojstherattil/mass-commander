#!/bin/bash

command_generator_for_acting_on_normal_users() {
	while read username; do
		commands_for_clients_to_run.sh "su - $username -c '"
		commands_for_clients_to_run.sh "$(cat $runtime_files_dir/custom_commands)"
		commands_for_clients_to_run.sh "'"
	done<$runtime_files_dir/normal_users_to_run_commands
}

custom_commands_fetcher() {
	echo "Enter the commands one by one and hit enter"
	while read entered_command; do
		#special_character_detector
		echo "$entered_command" | grep -qe '"' || echo "$entered_command" | grep -qe "'"
		if [ $? = 0 ]; then
			echo "please don't use quotations"
		else
			echo "$entered_command" >> $runtime_files_dir/custom_commands
		fi
	done
}

normal_usernames_fetcher() {
	echo "Enter usernames to act on:"

	while read username; do
		echo "$username" >> $runtime_files_dir/normal_users_to_run_commands
	done
}


echo "how would you like to login? (r)oot or (n)ormal user?"
echo -ne "r\nn\n" > $runtime_files_dir/input_options

user_input_validator.sh

user_input=$(cat $runtime_files_dir/user_input)

if [ "$user_input" = "n" ]; then
	normal_usernames_fetcher
	custom_commands_fetcher
	command_generator_for_acting_on_normal_users
elif [ "$user_input" = "r" ]; then
	custom_commands_fetcher
	commands_for_clients_to_run.sh "$(cat $runtime_files_dir/custom_commands)"
fi

commander.sh
