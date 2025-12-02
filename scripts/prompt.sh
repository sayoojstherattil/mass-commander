#!/bin/bash -e

trap 'echo -e "[${BASH_SOURCE}:${LINENO}]\t$BASH_COMMAND" ; read' DEBUG


echo -ne "What would you like to do?\n"
echo -ne "(i)nstall packages\n"
echo -ne "(r)emove packages\n"
echo -ne "(a)dd users\n"
echo -ne "(d)elete users\n"
echo -ne "(c)ustom commanding\n"

echo -ne "i\nr\na\nd\nc\n" > /$USER/mass-commander/runtime-files/input-options
/root/mass-commander/scripts/user-input-validator.sh

user_input=$(cat /$USER/mass-commander/runtime-files/user-input)

if [ "$user_input" = "i" ]; then
	user_choice="install_packages"
fi

if [ "$user_input" = "r" ]; then
	user_choice="remove_packages"
fi

if [ "$user_input" = "a" ]; then
	user_choice="add_users"
fi

if [ "$user_input" = "d" ]; then
	user_choice="delete_users"
fi

if [ "$user_input" = "c" ]; then
	user_choice="custom_commanding"
fi

echo "$user_choice" >> /$USER/mass-commander/runtime-files/user-choice
