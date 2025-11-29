#!/bin/bash

set -e

echo -ne "What would you like to do?\n"
echo -ne "(i)nstall packages\n"
echo -ne "(r)emove packages\n"
echo -ne "(a)dd users\n"
echo -ne "(d)elete users\n"
echo -ne "(c)ustom commanding\n"

echo -ne "i\nr\na\nd\nc\n" > choices
choice_validator.sh

if [ "$choice" = "i" ]; then
	echo -ne "How would you like to install?\n"
	echo -ne "(r)epo installation\n"
	echo -ne "(d)eb file installation\n"

	echo -ne "r\nd\n" > choices
	choice_validator.sh

	if [ "$choice" = "r" ]; then
		user_choice="installing_from_repo"
	elif [ "$choice" = "d" ]; then
		user_choice="installing_from_deb_file"
	fi
fi

if [ "$choice" = "r" ]; then
	user_choice="remove_packages"
fi

if [ "$choice" = "a" ]; then
	user_choice="add_users"
fi

if [ "$choice" = "d" ]; then
	user_choice="delete_users"
fi

if [ "$choice" = "c" ]; then
	user_choice="custom_commanding"
fi

echo "$user_choice" > user-choice
