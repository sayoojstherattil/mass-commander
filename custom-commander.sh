#!/bin/bash

set -e

echo -ne "how would you like to login? (r)oot or (n)ormal user?"
echo -ne "r\nn\n" > /$USER/mass-commander/runtime-files/input-options
/$USER/mass-commander/scripts/user-input-validator.sh

echo -ne "Enter the commands one by one and hit enter\n"

while read entered_command; do
	echo "$entered_command" >> /$USER/mass-commander/runtime-files/custom-commands
done

user_input=$(cat /$USER/mass-commander/runtime-files/user-input)

if [ "$user_input" = "n" ]; then
	user-fetcher.sh
	
	while read username; do
		echo "su - $username -c ' \\" >> /$USER/mass-commander/runtime-files/commands-to-run
		cat /$USER/mass-commander/runtime-files/custom-commands >> /$USER/mass-commander/runtime-files/commands-to-run
		echo "'" >> /$USER/mass-commander/runtime-files/commands-to-run
	done < /$USER/mass-commander/runtime-files/normal-users-to-run-commands
fi

/$USER/mass-commander/scripts/commander.sh
