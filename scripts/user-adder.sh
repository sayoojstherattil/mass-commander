#!/bin/bash

set -e

password_fetcher() {
	stty -echo

	echo -ne "enter password: "
	read entered_password
	echo -ne "enter again: "
	read rentered_password

	if [ "$entered_password" != "$rentered_password" ]; then
		echo -ne "sorry, the passwords do not match\n"
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

	echo "useradd $username -m -s /bin/bash" >> /$USER/mass-commander/runtime-files/commands-to-run
	echo "echo '$username:$password' | chpasswd" >> /$USER/mass-commander/runtime-files/commands-to-run

	echo -ne "do you like to add more users? (y)es/(n)o "
	echo -ne "y\nn\n" > /$USER/mass-commander/runtime-files/input-options
	/$USER/mass-commander/mass-commander/scripts/user-input-validator.sh

	user_input=$(cat /$USER/mass-commander/runtime-files/user_input)

	if [ "$user_input" = "y" ]; then
		looping=0
	fi
done

/$USER/mass-commander/mass-commander/scripts/commander.sh
