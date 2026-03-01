#!/bin/bash

echo "enter usernames one by one: "
while read username; do
	commands-for-clients-to-run.sh "userdel $username"
	commands-for-clients-to-run.sh "rm -r /home/$username"
	commands-for-clients-to-run.sh "echo user $username deleted"
done

commander.sh
