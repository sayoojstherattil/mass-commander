#!/bin/bash

echo "enter usernames one by one: "
while read username; do
	commands-for-clients-to-run.sh "userdel $username -r"
done

commander.sh
