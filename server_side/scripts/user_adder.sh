#!/bin/bash

password_fetcher() {
	stty -echo

	echo -ne "enter password: "
	read entered_password
	echo
	echo -ne "enter again: "
	read rentered_password
	echo

	if [ "$entered_password" != "$rentered_password" ]; then
		echo
		echo "sorry, the passwords do not match"
		echo
		password_fetcher
	else
		password="$entered_password"
	fi
	
	stty echo
}

looping=1

while [ $looping = 1 ]; do
	echo -ne "enter username: "
	read username

	password_fetcher

	commands_for_clients_to_run.sh "useradd $username -m -s /bin/bash"
	commands_for_clients_to_run.sh "echo '$username:$password' | chpasswd"

	commands_for_clients_to_run.sh "su - $username -c \"echo '../opener.sh >output 2>&1 &' >> .profile\""
	commands_for_clients_to_run.sh "su - $username -c \"touch one_doing\""
	commands_for_clients_to_run.sh "echo user $username added"

	echo -n "do you like to add more users? (y)es/(n)o "
	echo -ne "y\nn\n" > $runtime_files_dir/input_options

	user_input_validator.sh
	user_input=$(cat $runtime_files_dir/user_input)

	if [ "$user_input" = "n" ]; then
		looping=0
	fi
done

commander.sh
