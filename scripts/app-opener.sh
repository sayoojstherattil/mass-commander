#!/bin/bash -e

#shouldn't use here due to fail in opening apps in some users

app_to_open=$(cat /$USER/mass-commander/files-from-server/app-to-open)


app_opening_commands_generator() {
	line="$1"

	username=$(echo "$line" | awk -F' ' '{print $1}')
	display_number=$(echo "$line" | awk -F' ' '{print $11}')

	echo "su - $username -c '\\" >> /$USER/mass-commander/runtime-files/app-opening-commands
	echo "export DISPLAY=$display_number" >> /$USER/mass-commander/runtime-files/app-opening-commands
	echo "nohup $app_to_open &" >> /$USER/mass-commander/runtime-files/app-opening-commands
	echo "'" >> /$USER/mass-commander/runtime-files/app-opening-commands
}


w > /$USER/mass-commander/runtime-files/w-output
sed -i '1,2d' /$USER/mass-commander/runtime-files/w-output

while read line; do
	app_opening_commands_generator "$line"
done < /$USER/mass-commander/runtime-files/w-output

source /$USER/mass-commander/runtime-files/app-opening-commands
