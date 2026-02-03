#!/bin/bash

commands-for-clients-to-run.sh "apt update"
commands-for-clients-to-run.sh "apt upgrade -y"
commands-for-clients-to-run.sh "apt autoremove -y"

commander.sh
