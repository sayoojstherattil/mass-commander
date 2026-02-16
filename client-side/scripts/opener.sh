#!/bin/bash

while true; do
	if ! [ -f /home/$USER/one-doing ]; then
		export DISPLAY=<replace_with_display_number>
		gnome-terminal -- bash -c 'tail -f -n +1 /home/command-output; exec bash'
		touch /home/$USER/one-doing
	fi
done
