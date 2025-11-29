#!/bin/bash

set -e

read choice

choice_is_valid=0

while [ $choice_is_valid -e 0 ]; do
	while read choice_option; do
		if [ "$choice_option" = "$choice" ]; then
			choice_is_valid=1
			break
		fi
	done < choices

	if [ $choice_is_valid -e 0 ]; then
		echo -ne "Entered choice is invalid. Please try again\n"
		read choice
	fi
done

echo "$choice" > user_choice
