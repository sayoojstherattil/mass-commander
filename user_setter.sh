#!/bin/bash

echo -ne "Does any of the commands require root priviledges? (y)es/(n)o: "
choice_verifier

if [ "$root_privilege_choice" = "y" ]; then
	commanding_as_root="yes"
else 
	commanding_as_root="no"
	user_fetcher
fi

echo -ne "\n"
