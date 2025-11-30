#!/bin/bash

set -e

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> /$USER/mass-commander/runtime-files/packages-to-install
done

#package fetching here


echo 'apt-get install $(cat /$USER/mass-commander/files-from-server/packages-to-install)' > /$USER/mass-commander/runtime-files/commands-to-run

echo '/$USER/mass-commander/runtime-files/packages-to-install' >> /USER/mass-commander/runtime-files/files-to-tar
#also tar deb files

/$USER/mass-commander/scripts/commander.sh
