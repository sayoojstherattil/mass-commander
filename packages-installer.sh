#!/bin/bash

set -e

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> ./runtime-files/packages-to-install
	echo 'apt install $(cat ./files-from-server/packages-to-install)' > ./runtime-files/commands-to-run
done

echo './runtime-files/packages-to-install' >> files-to-tar

./scripts/commander.sh
