#!/bin/bash

set -e

echo -ne "enter usernames one by one: "
while read username; do
	user_delete_command="userdel $username -r"
	echo "$user_delete_command" >> commands-to-run-as-root
done
