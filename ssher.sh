#!/bin/bash

default_accessing_system_username="dell"
default_accessing_system_password="dell"

first_parameter="$1"
second_parameter="$2"
third_parameter="$3"

network_address=$(ip a | grep /24 | awk -F' ' '{printf "%s", $2}')
network_address_without_subnet=$(echo "$network_address" | awk -F'/' '{printf "%s", $1}')

if [ "$first_parameter" != "m" ] && [ "$first_parameter" != "s" ] && [ "$first_parameter" != "d" ] && [ "$first_parameter" != "" ]; then
	echo "first parameter is invalid"
	exit 1
fi

if [ "$second_parameter" != "m" ] && [ "$second_parameter" != "s" ] && [ "$second_parameter" != "d" ] && [ "$second_parameter" != "" ]; then
	echo "second parameter is invalid"
	exit 1
fi

if [ "$third_parameter" != "m" ] && [ "$third_parameter" != "s" ] && [ "$third_parameter" != "d" ] && [ "$third_parameter" != "" ]; then
	echo "third parameter is invalid"
	exit 1
fi


if [ "$first_parameter" == "s" ] || [ "$second_parameter" == "s" ] || [ "$third_parameter" == "s" ]; then
	command_seperator_for_command_string_executing_from_using_machine=";"
elif [ "$first_parameter" != "s" ] && [ "$second_parameter" != "s" ] && [ "$third_parameter" != "s" ]; then
	command_seperator_for_command_string_executing_from_using_machine="&"
fi

if [ "$first_parameter" == "d" ] || [ "$second_parameter" == "d" ] || [ "$third_parameter" == "d" ]; then
	command_seperator_for_command_string_for_all_accessing_systems=";"
elif [ "$first_parameter" != "d" ] && [ "$second_parameter" != "d" ] && [ "$third_parameter" != "d" ]; then
	command_seperator_for_command_string_for_all_accessing_systems="&&"
fi

username_array=()
password_array=()

if [ "$first_parameter" == "m" ] || [ "$second_parameter" == "m" ] || [ "$third_parameter" == "m" ]; then
	new_user="yes"
	echo -e "enter the details for users:\n"
	while [ "$new_user" == "yes" ]; do
		echo -n "enter username: "
		read next_username
		username_array+=("$next_username")

		echo -n "enter password: "
		read next_user_password 
		password_array+=("$next_user_password")

		more_user_invalid_choice="yes"
		while [ "$more_user_invalid_choice" == "yes" ]; do
			echo -en "\nmore users (y/n)?: "
			read more_user_choice
			if [ "$more_user_choice" == "n" ]; then
				new_user="no"
				more_user_invalid_choice="no"
			elif [ "$more_user_choice" == "y" ] || [ "$more_user_choice" == "" ]; then
				more_user_invalid_choice="no"
			else
				echo "invalid choice"
			fi

			echo
		done
	done

elif [ "$first_parameter" != "m" ] && [ "$second_parameter" != "m" ] && [ "$third_parameter" != "m" ]; then
		username_array+=("$default_accessing_system_username")
		password_array+=("$default_accessing_system_password")
fi

no_of_users=${#username_array[@]}

command_string_for_all_accessing_systems="echo reading commands for accessing systems..."
echo "enter commands to run. after each command, press enter. after all, Ctrl+d:"
while read entered_command; do
        command_string_for_all_accessing_systems="$command_string_for_all_accessing_systems $command_seperator_for_command_string_for_all_accessing_systems $entered_command"
done

perform_choice_invalid_choice="yes"
while [ "$perform_choice_invalid_choice" == "yes" ]; do
	echo -en "\ndo you want to perform in this system (y/n)?: "
	read perform_choice
	if [ "$perform_choice" != "y" ] && [ "$perform_choice" != "n" ]; then
		echo "invalid choice"
	else
		perform_choice_invalid_choice="no"
	fi
done

power_choice_invalid_choice="yes"
while [ "$power_choice_invalid_choice" == "yes" ]; do
	echo -ne "\nshutdown (s) or reboot (r) or nothing (n)?: "
	read power_choice
	if [ "$power_choice" != "s" ] && [ "$power_choice" != "r" ] && [ "$power_choice" != "n" ]; then
		echo "invalid choice"
	else
		power_choice_invalid_choice="no"
	fi
done

echo -e "\naccessing the systems....\n"

address_string=$(nmap -sn "$network_address" | grep "Nmap scan report for" | awk -F' ' '{printf "%s ", $5}')

address_array=()
IFS=' ' read -r -a address_array <<< "$address_string"

command_string_to_execute_from_using_machine="echo starting in using system..."

for ((i = 0; i < $no_of_users; i++)); do
	accessing_system_username="${username_array[$i]}"
	accessing_system_password="${password_array[$i]}"

	command_string_for_accessing_system="echo '$accessing_system_password' | sudo -S echo starting in accessing system... && $command_string_for_all_accessing_systems"

	for address in ${address_array[@]}; do
		if [ "$address" != "$network_address_without_subnet" ]; then
			command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine $command_seperator_for_command_string_executing_from_using_machine sshpass -p \"$accessing_system_password\" ssh -t -o \"StrictHostKeyChecking no\" -o UserKnownHostsFile=/dev/null \"$accessing_system_username\"@\"$address\" \"$command_string_for_accessing_system\""
		fi
	done

	if [ "$perform_choice" == "y" ]; then
			command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine $command_seperator_for_command_string_executing_from_using_machine sshpass -p \"$accessing_system_password\" ssh -t -o \"StrictHostKeyChecking no\" -o UserKnownHostsFile=/dev/null \"$accessing_system_username\"@\"$network_address_without_subnet\" \"$command_string_for_accessing_system\""
	fi
done

if [ "$power_choice" == "s" ]; then
	command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine $command_seperator_for_command_string_executing_from_using_machine doing mass shutdown..."
	for address in ${address_array[@]}; do
		if [ "$address" != "$network_address_without_subnet" ]; then
		command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine & sshpass -p \"$default_accessing_system_password\" ssh -t -o \"StrictHostKeyChecking no\" -o UserKnownHostsFile=/dev/null \"$default_accessing_system_username\"@\"$address\" \"sudo systemctl poweroff\""
		fi
	done

	if [ "$perform_choice" == "y" ]; then
		command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine & sshpass -p \"$default_accessing_system_password\" ssh -t -o \"StrictHostKeyChecking no\" -o UserKnownHostsFile=/dev/null \"$default_accessing_system_username\"@\"$network_address_without_subnet\" \"sudo systemctl poweroff\""
	fi
elif [ "$power_choice" == "r" ]; then
	command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine $command_seperator_for_command_string_executing_from_using_machine doing mass reboot..."
	for address in ${address_array[@]}; do
		if [ "$address" != "$network_address_without_subnet" ]; then
		command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine & sshpass -p \"$default_accessing_system_password\" ssh -t -o \"StrictHostKeyChecking no\" -o UserKnownHostsFile=/dev/null \"$default_accessing_system_username\"@\"$address\" \"sudo systemctl reboot\""
		fi
	done

	if [ "$perform_choice" == "y" ]; then
		command_string_to_execute_from_using_machine="$command_string_to_execute_from_using_machine & sshpass -p \"$default_accessing_system_password\" ssh -t -o \"StrictHostKeyChecking no\" -o UserKnownHostsFile=/dev/null \"$default_accessing_system_username\"@\"$network_address_without_subnet\" \"sudo systemctl reboot\""
	fi
fi

#echo "$command_string_to_execute_from_using_machine"
bash -c "$command_string_to_execute_from_using_machine"
