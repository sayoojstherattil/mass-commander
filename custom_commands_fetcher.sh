#!/bin/bash

set -e

echo -ne "Does any of the commands require root priviledges? (y)es/(n)o: "
echo -ne "y\nn\n" > choices
choice_validator.sh

if [ "$root_privilege_choice" = "y" ]; then
	echo "root_user" > user-login-type
else 
	echo "normal_user" > user-login-type
	user-fetcher
fi

echo -ne "Enter the commands one by one and hit enter"

while read entered_command; do
	echo "$entered_command" >> custom-commands
done

#commanding

