#!/bin/bash

echo "performing systems reboot..."
commands_for_clients_to_run.sh "echo -n 'Rebooting in 3..'"
commands_for_clients_to_run.sh "sleep 1"
commands_for_clients_to_run.sh "echo -n '2..'"
commands_for_clients_to_run.sh "sleep 1"
commands_for_clients_to_run.sh "echo -n '1..'"
commands_for_clients_to_run.sh "sleep 1"

commands_for_clients_to_run.sh "systemctl reboot"

commander.sh
