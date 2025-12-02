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
		echo -ne "sorry, the passwords do not match\n"
		password_fetcher
	else
		password="$entered_password"
	fi
	
	stty echo
}

looping="1"

while [ "$looping" = "1" ]; do
	echo -ne "enter username: "
	read username

	password_fetcher

	echo "useradd $username -m -s /bin/bash" >> /root/mass-commander/runtime-files/commands-to-run
	echo "echo '$username:$password' | chpasswd" >> /root/mass-commander/runtime-files/commands-to-run

	echo -ne "do you like to add more users? (y)es/(n)o "
	echo -ne "y\nn\n" > /root/mass-commander/runtime-files/input-options
	/root/mass-commander/scripts/user-input-validator.sh

	user_input=$(cat /root/mass-commander/runtime-files/user-input)

	if [ "$user_input" = "n" ]; then
		looping=0
	fi
done

/root/mass-commander/scripts/commander.sh
