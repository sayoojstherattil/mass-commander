#!/bin/bash

#shouldn't use here due to fail in opening apps in some users

app_to_open=$(cat /root/mass-commander/files-from-server/app-to-open)


app_opening_commands_generator() {
	line="$1"

	username=$(echo "$line" | awk -F' ' '{print $1}')
	display_number=$(echo "$line" | awk -F' ' '{print $11}')

	echo "su - $username -c '\\" >> /root/mass-commander/runtime-files/app-opening-commands
	echo "export DISPLAY=$display_number" >> /root/mass-commander/runtime-files/app-opening-commands
	echo "nohup $app_to_open &" >> /root/mass-commander/runtime-files/app-opening-commands
	echo "'" >> /root/mass-commander/runtime-files/app-opening-commands
}


w > /root/mass-commander/runtime-files/w-output
sed -i '1,2d' /root/mass-commander/runtime-files/w-output

while read line; do
	app_opening_commands_generator "$line"
done < /root/mass-commander/runtime-files/w-output

source /root/mass-commander/runtime-files/app-opening-commands
