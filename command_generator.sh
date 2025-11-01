#!/bin/bash

if [ "$custom_commanding" = "on"]; then
	if [ "$root_privilege_choice" = "y" ]; then
		for line in "${command_array[@]}"; do
			echo "$line && \\" >> commands_to_be_ran_as_root
		done
	else
		for line in "${command_array[@]}"; do
			echo "$line && \\" >> commands_to_be_ran_as_normal_user
		done
	fi
fi

if [ "$last_thing_to_do" = "open_gui_app" ]; then
	export DISPLAY=:0
	echo "nohup $app_package_name>/dev/null 2>&1 &" >> commands_to_be_ran_as_normal_user
elif [ "$last_thing_to_do" = "reboot" ]; then
		echo "$reboot_command" >> commands_to_be_ran_as_root_user
elif [ "$last_thing_to_do" = "poweroff" ]; then
		echo "$poweroff_command" >> commands_to_be_ran_as_root_user
fi
