#!/bin/bash

set -e

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> ./runtime-files/packages-to-remove
	echo 'apt remove $(cat ./files-from-server/packages-to-remove) -y' > ./runtime-files/commands-to-run
	echo "apt autoremove -y" >> ./runtime-files/commands-to-run
done

echo './runtime-files/packages-to-remove' >> files-to-tar

./scripts/commander.sh
