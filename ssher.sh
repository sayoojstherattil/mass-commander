#!/bin/bash

accessing_system_password="dell"
accessing_system_username="dell"

network_address=$(ip a | grep /24 | awk -F' ' '{printf "%s", $2}')
network_address_without_subnet=$(echo "$network_address" | awk -F'/' '{printf "%s", $1}')

echo -n "do you want to perform in this system (y/n)?: "
read perform_choice
echo -n "shutdown (s) or reboot (r) or nothing (n)?: "
read power_choice

command_string_for_accessing_system="echo '$accessing_system_password' | sudo -S echo starting in accessing system..."
echo "enter commands to run. after each command, press enter. after all, Ctrl+d:"
while read entered_command
do
        command_string_for_accessing_system="$command_string_for_accessing_system && $entered_command"
done

if [ "$power_choice" == "s" ]; then
	command_string_for_accessing_system="$command_string_for_accessing_system && sudo systemctl poweroff"
elif [ "$power_choice" == "r" ]; then
	command_string_for_accessing_system="$command_string_for_accessing_system && sudo systemctl reboot"
elif [ "$power_choice" != "n" ]; then
	echo "invalid powering option"
	exit 1
fi

echo -e "\naccessing the systems....\n"

address_string=$(nmap -sn "$network_address" | grep "Nmap scan report for" | awk -F' ' '{printf "%s ", $5}')

address_array=()
IFS=' ' read -r -a address_array <<< "$address_string"

command_string_to_execute_from_using_machine="echo starting in using system..."


for address in ${address_array[@]};
do
	if [ "$address" != "$network_address_without_subnet" ]; then
		command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine & sshpass -p \"$accessing_system_password\" ssh -t -o \"StrictHostKeyChecking no\" -o UserKnownHostsFile=/dev/null \"$accessing_system_username\"@\"$address\" \"$command_string_for_accessing_system\""
	fi
done

if [ "$perform_choice" == "y" ]; then
		command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine & sshpass -p \"$accessing_system_password\" ssh -t -o \"StrictHostKeyChecking no\" -o UserKnownHostsFile=/dev/null \"$accessing_system_username\"@\"$network_address_without_subnet\" \"$command_string_for_accessing_system\""
elif  [ "$perform_choice" != "n" ]; then
	echo "invalid choice"
	exit 1
fi

#echo "$command_string_to_execute_from_using_machine"
bash -c "$command_string_to_execute_from_using_machine"
