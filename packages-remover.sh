#!/bin/bash

set -e

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> ./runtime-files/packages-to-remove
	#echo "apt remove $(cat packages-to-install) -y" > commands-to-run-as-root
	#echo "apt autoremove -y" >> commands-to-run-as-root
done
