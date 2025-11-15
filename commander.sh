#!/bin/bash

set -e

who_commanded="$1"

root_user_commander() {
	while read ip_address; do	
		scp commands-to-run-as-root-user root@"ip_address":"$files_location" &
	done <ip-address-pool

	while read ip_address; do	
		ssh root@"ip_address" "[ -f $files_location/commands-to-run-as-root-user ] cat $files_location | bash" 
	done <ip-address-pool
}

normal_user_commander() {
	for username in "${username}"; do
	while read ip_address; do	
		scp commands-to-run-as-normal-user "$username"@"ip_address":"$files_location" &
	done <ip-address-pool

	while read ip_address; do	
		ssh "$username"@"ip_address" "cat $files_location | bash" 
	done <ip-address-pool
}

#alive_systems_finder

if [ "$who_commanded" = "r" ]; then
	root_user_commander
elif [ "$who_commanded" = "n" ]; then
	command_generator_for_normal_user
elif [ "$who_commanded" = "b" ]; then
	root_user_commander
	command_generator_for_normal_user
fi
