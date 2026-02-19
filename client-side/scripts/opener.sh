#!/bin/bash

while true; do
	if ! [ -f /home/$USER/one-doing ]; then
		export DISPLAY=$(cat /root/mass-commander/display_number_of_this_machine)
		gnome-terminal -- bash -c 'tail -f -n +1 /home/command-output; exec bash'
		touch /home/$USER/one-doing
	fi
done
