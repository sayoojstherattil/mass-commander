#!/bin/bash

display_number=$(w | grep $USER | awk -F' ' '{print $2}' | grep -e :)

while true; do
	if ! [ -f /home/$USER/one-doing ]; then
		export DISPLAY="$display_number"
		gnome-terminal -- bash -c 'tail -f -n +1 /home/command-output; exec bash'
		touch /home/$USER/one-doing
	fi
done
