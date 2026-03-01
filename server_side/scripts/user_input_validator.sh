#!/bin/bash

input_is_valid=0

while [ $input_is_valid = 0 ]; do
	read input

	if [ -z $input ]; then
		echo "please enter something"
	else
		while read input_option; do
			if [ $input_option = $input ]; then
				input_is_valid=1
				break
			fi
		done<$runtime_files_dir/input_options

		if [ $input_is_valid -eq 1 ]; then
			break
		else
			echo "Entered input is invalid. Please try again"
		fi
	fi
done

echo "$input" > $runtime_files_dir/user_input
