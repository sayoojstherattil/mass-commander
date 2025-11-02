#!/bin/bash

set -e

app_package_name="nautilus"

if [ "$wish_of_user" = "adding_users" ]; then
	user_adder
elif [ "$wish_of_user" = "removing_users" ]; then
	user_remover
elif [ "$wish_of_user" = "installing_packages_from_repo" ]; then
	packages_from_repo_installer
elif [ "$wish_of_user" = "deb_file_installer" ]; then
	packages_from_deb_file_installer
elif [ "$wish_of_user" = "custom_commanding" ]; then
	custom_commanding="on"
	user_setter
	custom_commands_fetcher
	command_files_generator
	command_files_sender_and_executor
else
	echo -ne "You wished something not in the list\n"
fi
