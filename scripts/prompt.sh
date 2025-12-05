#!/bin/bash

echo "What would you like to do?"
echo "(i)nstall packages"
echo "(r)emove packages"
echo "(a)dd users"
echo "(d)elete users"
echo "(c)ustom commanding"
echo

echo -ne "i\nr\na\nd\nc\n" > $runtime_files_dir/input-options
user-input-validator.sh

user_input=$(cat $runtime_files_dir/user-input)

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

echo "$user_choice" > $runtime_files_dir/user-choice
