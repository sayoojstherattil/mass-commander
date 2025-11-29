#!/bin/bash

set -e

echo -ne "Does any of the commands require root priviledges? (y)es/(n)o: "
echo -ne "y\nn\n" > choices
choice_validator.sh

if [ "$root_privilege_choice" = "y" ]; then
	commanding_as_root=1
else 
	commanding_as_root=0
	user-fetcher
fi
