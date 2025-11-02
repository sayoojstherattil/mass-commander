#!/bin/bash

command_to_send_to_each_device="nc -lp $normal_user_file_nc_port > /tmp/mass-commander/commands_to_run_as_normal_user & nc -lp $root_user_file_nc_port > /tmp/mass-commander/commands_to_run_as_root_user && $(cat /tmp/mass-commander/commands_to_run_as_normal_user) && $(cat /tmp/mass-commander/commands_to_run_as_root_user)" 
