#!/bin/bash

set -e

echo -ne "enter usernames one by one: "
while read username; do
	echo "userdel $username -r" >> /$USER/mass-commander/runtime-files/commands-to-run
done

/$USER/mass-commander/scripts/commander.sh
