#!/bin/bash

set -e

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> /$USER/mass-commander/runtime-files/packages-to-remove
done

echo 'apt remove $(cat /$USER/mass-commander/files-from-server/packages-to-remove) -y' > /$USER/mass-commander/runtime-files/commands-to-run
echo "apt autoremove -y" >> /$USER/mass-commander/runtime-files/commands-to-run

echo '/$USER/mass-commander/runtime-files/packages-to-remove' >> files-to-tar

/$USER/mass-commander/scripts/commander.sh
