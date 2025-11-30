#!/bin/bash

set -e

echo -ne "enter names of packages one by one: "

while read package_name; do
	echo "$package_name" >> packages-to-install
	echo "apt install $(cat packages-to-install) -y" > commands-to-run-as-root
done
