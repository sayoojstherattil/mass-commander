#!/bin/bash



echo -ne "Enter usernames to act on:\n"

while read username; do
	echo "$username" >> /root/mass-commander/runtime-files/normal-users-to-run-commands
done
