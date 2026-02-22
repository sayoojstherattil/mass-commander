#!/bin/bash

echo "performing systems reboot..."
commands-for-clients-to-run.sh "echo -n 'Rebooting in 3..'"
commands-for-clients-to-run.sh "sleep 1"
commands-for-clients-to-run.sh "echo -n '2..'"
commands-for-clients-to-run.sh "sleep 1"
commands-for-clients-to-run.sh "echo -n '1..'"
commands-for-clients-to-run.sh "sleep 1"

commands-for-clients-to-run.sh "systemctl reboot"

commander.sh
