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

	commands-for-clients-to-run.sh "useradd $username -m -s /bin/bash"
	commands-for-clients-to-run.sh "echo '$username:$password' | chpasswd"

	commands-for-clients-to-run.sh "su - $username -c \"echo '../opener.sh & >output 2>&1' >> .profile\""
	commands-for-clients-to-run.sh "echo user $username added"

	echo -n "do you like to add more users? (y)es/(n)o "
	echo -ne "y\nn\n" > $runtime_files_dir/input-options

	user-input-validator.sh
	user_input=$(cat $runtime_files_dir/user-input)

	if [ "$user_input" = "n" ]; then
		looping=0
	fi
done

commander.sh
