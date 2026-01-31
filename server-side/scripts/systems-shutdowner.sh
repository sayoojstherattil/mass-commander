#!/bin/bash

commands-for-clients-to-run.sh "echo -n 'Shutting down in 3..'"
commands-for-clients-to-run.sh "echo -n '2..'"
commands-for-clients-to-run.sh "echo -n '1..'"

commands-for-clients-to-run.sh "systemctl poweroff"
