#!/bin/bash

set -e

echo -ne "Does any of the commands require root priviledges? (y)es/(n)o: "
echo -ne "y\nn\n" > input_options
choice_validator.sh

user_input=$(cat user_input)

if [ "$user_input" = "y" ]; then
	echo "root_user" > user-login-type
else 
	echo "normal_user" > user-login-type
	user-fetcher.sh
fi

echo -ne "Enter the commands one by one and hit enter\n"

while read entered_command; do
	echo "$entered_command" >> custom-commands
done

commander.sh
