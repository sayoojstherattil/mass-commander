#!/bin/bash

command_to_append="$1"

echo "$command_to_append" >> $runtime_files_dir/commands-to-run-of-client
