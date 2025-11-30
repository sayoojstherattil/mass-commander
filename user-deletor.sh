#!/bin/bash

set -e

echo -ne "enter usernames one by one: "
while read username; do
	echo "userdel $username -r" >> ./runtime-files/commands-to-run-as-root
done
