#!/bin/bash

echo -ne "Enter usernames to act on:\n"

while read username; do
	echo "$username" >> normal-users-to-run-commands
done
