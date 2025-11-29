#!/bin/bash

set -e

app_package_name="nautilus"

prompt.sh

if [ "$wish_of_user" = "adding_users" ]; then
	user-adder.sh
elif [ "$wish_of_user" = "removing_users" ]; then
	user-remover.sh
elif [ "$wish_of_user" = "installing_packages_from_repo" ]; then
	packages-from-repo-installer.sh
elif [ "$wish_of_user" = "deb_file_installer" ]; then
	packages_from_deb_file_installer.sh
elif [ "$wish_of_user" = "custom_commanding" ]; then
	custom_commanding="on"
	custom_commands_fetcher.sh
else
	echo -ne "You wished something not in the list\n"
fi
