#!/bin/bash

set -e

looping=1

while [ $looping = 1 ]; do
	echo -ne "enter username: "
	read username
	echo -ne "enter password: "
	read password

	useradd_command="useradd $username -m -p $password -s /bin/bash"

	echo "$useradd_command" >> commands-to-run-as-root

	echo -ne "do you like to add more users? (y)es/(n)o "
	read user_choice

	#prompt verification here

	if [ "$user_choice" = "yes" ]; then
		looping=0
	fi
done
