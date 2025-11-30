#!/bin/bash

set -e

read input

input_is_valid=0

while [ $input_is_valid -e 0 ]; do
	while read input_option; do
		if [ "$input_option" = "$input" ]; then
			input_is_valid=1
			break
		fi
	done < input_options

	if [ $input_is_valid -e 0 ]; then
		echo -ne "Entered input is invalid. Please try again\n"
		read input
	fi
done

echo "$input" > user_input
