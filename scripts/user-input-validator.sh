#!/bin/bash

trap 'echo -e "[${BASH_SOURCE}:${LINENO}]\t$BASH_COMMAND" ; read' DEBUG

read input

input_is_valid="0"

while [ "$input_is_valid" = "0" ]; do
	while read input_option; do
		echo "input is $input"
		echo "input option is $input_option"
		if [ "$input_option" = "$input" ]; then
			echo "input is valid"
			input_is_valid="1"
			echo "breaking..."
			break
			echo "couldn't break.."
		fi
	done</root/mass-commander/runtime-files/input-options

	if [ "$input_is_valid" = "0" ]; then
		echo -ne "Entered input is invalid. Please try again\n"
		read input
	fi
done

echo "$input" > /$USER/mass-commander/runtime-files/user-input
