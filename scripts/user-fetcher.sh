#!/bin/bash -e


echo -ne "Enter usernames to act on:\n"

while read username; do
	echo "$username" >> /$USER/mass-commander/runtime-files/normal-users-to-run-commands
done
