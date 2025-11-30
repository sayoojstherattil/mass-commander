#!/bin/bash

set -e

prompt.sh

if [ "$wish_of_user" = "add_users" ]; then
	./scripts/user-adder.sh
elif [ "$wish_of_user" = "delete_users" ]; then
	user-deletor.sh
elif [ "$wish_of_user" = "install_packages" ]; then
	packages-installer.sh
elif [ "$wish_of_user" = "remove_packages" ]; then
	packages-remover.sh
elif [ "$wish_of_user" = "custom_commanding" ]; then
	custom-commander.sh
fi
