#!/bin/bash

echo "performing systems shutdown..."
commands_for_clients_to_run.sh "echo -n 'Shutting down in 3..'"
commands_for_clients_to_run.sh "sleep 1"
commands_for_clients_to_run.sh "echo -n '2..'"
commands_for_clients_to_run.sh "sleep 1"
commands_for_clients_to_run.sh "echo -n '1..'"
commands_for_clients_to_run.sh "sleep 1"

commands_for_clients_to_run.sh "systemctl poweroff"

commander.sh
