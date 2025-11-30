#!/bin/bash

set -e

echo -ne "how would you like to login? (r)oot or (n)ormal user?"
echo -ne "r\nn\n" > ./runtime-files/input-options
./scripts/user-input-validator.sh

user_input=$(cat ./runtime-files/user-input)

echo -ne "Enter the commands one by one and hit enter\n"

while read entered_command; do
	echo "$entered_command" >> custom-commands
done

if [ "$user_input" = "n" ]; then
	user-fetcher.sh
	
	while read username; do
		echo "su - $username -c ' \\" >> ./runtime-files/commands-to-run
		cat ./runtime-files/custom-commands >> ./runtime-files/commands-to-run
		echo "'" >> ./runtime-files/commands-to-run
	done < normal-users-to-run-commands
fi

commander.sh
