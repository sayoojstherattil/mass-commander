#!/bin/bash

while true; do
	if ! [ -f /home/$USER/one_doing ]; then
		export DISPLAY=$(cat /home/display_number_of_this_machine)
		gnome_terminal -_ bash -c 'tail -f -n +1 /home/command_output; exec bash'
		touch /home/$USER/one_doing
	fi
done
