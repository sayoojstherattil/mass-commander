#!/bin/bash

echo -ne "Does any of the commands require root priviledges (y)es/(n)o?"
read root_privilege_choice

if [ "$root_privilege_choice" = "y" ]; then
	echo -ne "Enter root privilege gaining password: "
	read root_privilege_gaining_password
	#need to find a way to prevent echoeing
	echo -ne "\n"
else 
	user_fetcher
fi
