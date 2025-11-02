#!/bin/bash

echo -ne "Enter the commands one by one and hit enter"
while read read_line; do
	commands_array+=("$read_line")
done

echo -ne "\n"

echo -ne "What do you wish to perform at the end? (r)eboot/(p)ower off/(o)pen predefined gui application: "
read last_thing_to_do_choice
choice_verifier

if [ "$last_thing_to_do_choice" = "r" ]; then
	last_thing_to_do="reboot"
elif [ "$last_thing_to_do_choice" = "p" ]; then
	last_thing_to_do="poweroff"
elif [ "$last_thing_to_do_choice" = "o" ]; then
	last_thing_to_do="open_gui_app"
fi

echo -ne "\n"
