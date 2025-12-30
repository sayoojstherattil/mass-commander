#!/bin/bash

password_fetcher() {
	stty -echo

	echo -ne "enter password: "
	read entered_password
	echo -ne "enter again: "
	read rentered_password

	if [ "$entered_password" -ne "$rentered_password" ]; then
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

while [ $looping -e 1 ]; do
	echo -ne "enter username: "
	read username

	password_fetcher

	echo "useradd $username -m -s /bin/bash" >> $runtime_files_dir/commands-to-run
	echo "echo '$username:$password' | chpasswd" >> $runtime_files_dir/commands-to-run

	echo -n "do you like to add more users? (y)es/(n)o "
	echo -ne "y\nn\n" > $runtime_files_dir/input-options

	user-input-validator.sh
	user_input=$(cat $runtime_files_dir/user_input)

	if [ "$user_input" = "y" ]; then
		looping=0
	fi
done

commander.sh
