#!/bin/bash

echo "enter usernames one by one: "
while read username; do
	commands_for_clients_to_run.sh "userdel $username"
	commands_for_clients_to_run.sh "rm -r /home/$username"
	commands_for_clients_to_run.sh "echo user $username deleted"
done

commander.sh
