#!/bin/bash

app_to_open=$(cat $runtime_files_dir_of_client/app-to-open)


app_opening_commands_generator() {
	line="$1"

	username=$(echo "$line" | awk -F' ' '{print $1}')
	display_number=$(echo "$line" | awk -F' ' '{print $11}')

	echo "su - $username -c '\\" >> $runtime_files_dir_of_client/app-opening-commands
	echo "export DISPLAY=$display_number" >> $runtime_files_dir_of_client/app-opening-commands
	echo "$app_to_open &" >> $runtime_files_dir_of_client/app-opening-commands
	echo "'" >> $runtime_files_dir_of_client/app-opening-commands
}


w > $runtime_files_dir_of_client/w-output
sed -i '1,2d' $runtime_files_dir_of_client/w-output

while read line; do
	app_opening_commands_generator "$line"
done<$runtime_files_dir_of_client/w-output

source $runtime_files_dir_of_client/app-opening-commands
