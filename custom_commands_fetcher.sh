#!/bin/bash

user_to_run_as="$1"

echo -ne "Enter the commands one by one and hit enter"

if [ "$user_to_run_as" = "r" ]; then
	while read entered_command; do
		echo "$entered_command" >> commands-to-run-as-root-user
	done

	echo -ne "would you like to (r)eboot or (s)hutdown or (n)othing? "
	#prompt verifier
	read user_choice

	if [ "$user_choice" = "r" ]; then
		echo "$reboot_command" >> commands-to-run-as-root-user
	elif [ "$user_choice" = "s" ]; then
		echo "$shutdown_command" >> commands-to-run-as-root-user
	fi
else
	while read entered_command; do
		echo "$entered_command" >> commands-to-run-as-normal-user
		echo "$app_open_command" >> commands-to-run-as-normal-user
	done
fi
