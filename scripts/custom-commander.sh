#!/bin/bash



echo -ne "how would you like to login? (r)oot or (n)ormal user?"
echo -ne "r\nn\n" > /root/mass-commander/runtime-files/input-options
/root/mass-commander/scripts/user-input-validator.sh

echo -ne "Enter the commands one by one and hit enter\n"

while read entered_command; do
	echo "$entered_command" >> /root/mass-commander/runtime-files/custom-commands
done

user_input=$(cat /root/mass-commander/runtime-files/user-input)

if [ "$user_input" = "n" ]; then
	user-fetcher.sh
	
	while read username; do
		echo "su - $username -c ' \\" >> /root/mass-commander/runtime-files/commands-to-run
		cat /root/mass-commander/runtime-files/custom-commands >> /root/mass-commander/runtime-files/commands-to-run
		echo "'" >> /root/mass-commander/runtime-files/commands-to-run
	done < /root/mass-commander/runtime-files/normal-users-to-run-commands
fi

/root/mass-commander/scripts/commander.sh
