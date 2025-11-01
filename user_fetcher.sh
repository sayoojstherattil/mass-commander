#!/bin/bash

echo -ne "Enter usernames to act on:\n"

while read read_line; do
	users_to_be_accessed_array+=("$read_line")
done

echo -ne "\n"
