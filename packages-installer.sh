#!/bin/bash

set -e

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> ./runtime-files/packages-to-install
	echo 'apt install $(cat ./runtime-files/packages-to-install)'
	echo './runtime-files/packages-to-install' > ./runtime-files/files-to-send
done
