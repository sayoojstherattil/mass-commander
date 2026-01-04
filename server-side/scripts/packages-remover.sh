#!/bin/bash

apt_package_remover() {
	echo "enter names of apt packages one by one: "

	while read apt_package_name; do
		commands-for-clients-to-run.sh "apt remove -y $apt_package_name"
	done

	commands-for-clients-to-run.sh "apt autoremove -y"
}

snap_remover() {
	echo "enter names of snaps one by one: "

	while read snap_package_name; do
		commands-for-clients-to-run.sh "removing ${snap_package_name}..."
		commands-for-clients-to-run.sh "snap remove $snap_package_name"
	done
}

echo "(a)pt packages"
echo "(s)nap packages"

echo -ne "a\ns\n" > $runtime_files_dir/input-options
user-input-validator.sh
echo

user_input=$(cat $runtime_files_dir/user-input)

if [ $user_input = "s" ]; then
	snap_remover
else
	apt_package_remover
fi

commander.sh
