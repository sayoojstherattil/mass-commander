#!/bin/bash

echo -ne "Enter the commands one by one and hit enter"
while read read_line; do
	commands_array+=("$read_line")
done

command_generator
