#!/bin/bash

read input

input_is_valid="0"

while [ "$input_is_valid" = "0" ]; do
	while read input_option; do
		if [ "$input_option" = "$input" ]; then
			input_is_valid="1"
			break
		fi
	done<$runtime_files_dir/input-options

	if [ "$input_is_valid" = "0" ]; then
		echo -ne "Entered input is invalid. Please try again\n"
		read input
	fi
done

echo "$input" > $runtime_files_dir/user-input
