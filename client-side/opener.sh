#!/bin/bash

command_status=$(cat /home/command-status)
process_acting=$(cat /home/sayooj/open-status)

while true; do
	if [ "$command_status" = "just now executed successfully" ] && [ "$process_acting" = 0 ]; then
		export DISPLAY=:0
		gnome-terminal -- bash -c 'tail -f -n +1 /home/command-output'
		echo 1 > /home/sayooj/open-status
	fi

	command_status=$(cat /home/command-status)
	process_acting=$(cat /home/sayooj/open-status)
done
