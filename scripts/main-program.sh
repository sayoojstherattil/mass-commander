#!/bin/bash -e

trap 'echo -e "[${BASH_SOURCE}:${LINENO}]\t$BASH_COMMAND" ; read' DEBUG


/root/mass-commander/scripts/prompt.sh

user_choice=$(cat /$USER/mass-commander/runtime-files/user-choice)

if [ "$user_choice" = "add_users" ]; then
	/$USER/mass-commander/scripts/user-adder.sh
elif [ "$user_choice" = "delete_users" ]; then
	/$USER/mass-commander/scripts/user-deletor.sh
elif [ "$user_choice" = "install_packages" ]; then
	/$USER/mass-commander/scripts/packages-installer.sh
elif [ "$user_choice" = "remove_packages" ]; then
	/$USER/mass-commander/scripts/packages-remover.sh
elif [ "$user_choice" = "custom_commanding" ]; then
	/$USER/mass-commander/scripts/custom-commander.sh
fi
