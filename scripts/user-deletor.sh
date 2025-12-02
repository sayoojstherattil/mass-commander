#!/bin/bash



echo -ne "enter usernames one by one: "
while read username; do
	echo "userdel $username -r" >> /root/mass-commander/runtime-files/commands-to-run
done

/root/mass-commander/scripts/commander.sh
